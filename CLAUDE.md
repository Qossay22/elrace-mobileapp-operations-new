# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

El Race is a Flutter mobile app (package name `el_race`) for a construction/operations company: HR requests, attendance & face-recognition timesheets, project/site management, purchase (LPO/RFQ), payslips, performance evaluations, recruitment, chat, reports, tasks/tickets, and a Firebase-backed notification system. It targets Android and iOS, uses Firebase (Auth, Firestore, Storage, Realtime DB, Messaging, Crashlytics) plus two Cloud Functions codebases, and integrates AWS Rekognition/on-device TFLite for face liveness.

## Common commands

```powershell
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Run all tests
flutter test --no-pub

# Run a single test file
flutter test --no-pub test\home\home_widget_visibility_test.dart

# Run a single test by name
flutter test --no-pub test\hr_management\hr_effective_view_test.dart --plain-name "some test name"

# Static analysis (project convention: pass explicit paths for a fast, focused check
# instead of a full-repo `flutter analyze`, which is slow on this codebase)
flutter analyze --no-pub lib\path\to\touched_file.dart

# Build
flutter build apk
flutter build ios

# State-management marker audit (counts BLoC vs Provider vs Riverpod vs GetX usage in lib/)
powershell -ExecutionPolicy Bypass -File .\scripts\state_management_audit.ps1

# Regenerate PROJECT_FILE_INDEX.md (run after adding/removing/renaming files under lib/)
powershell -ExecutionPolicy Bypass -File .\scripts\generate_project_file_index.ps1
```

Cloud Functions (`functions/` = chat notifications, `functions-liveness/` = AWS Rekognition liveness) are separate Node projects:

```bash
cd functions && npm install        # or functions-liveness
firebase emulators:start --only functions
firebase deploy --only functions
```

## Architecture

### App bootstrap (`lib/main.dart`)

Startup is split into phases to get the native splash off-screen fast and never hard-crash on a startup error:

1. A global error guard (`_installGlobalErrorGuard`) is installed before anything else — it swallows `FlutterError`/`PlatformDispatcher` errors (including `StackOverflowError` from runaway async chains) so a single unhandled error can't crash the app in production; it logs a deduped breadcrumb instead.
2. `initDI()` (get_it) runs **before** `runApp()` — `MyApp` resolves several blocs from the service locator during its first build, so DI must already be populated (see `_verifyStartupDependencies`, which throws if a required singleton is missing).
3. **Phase 1** (blocking, must finish before `runApp`): `SharedPref`, `Firebase.initializeApp()`, `DeviceUiCapability`, localization delegate — all with short timeouts and fallbacks so a slow/broken step degrades instead of hanging.
4. `runApp()` fires immediately after Phase 1.
5. **Phase 2+** (`addPostFrameCallback` → `_performHeavyInitialization`): Hive, `AppConfigService`, `FirebaseService`, then non-critical background services (WorkManager periodic tasks, prayer/checkout/counter services, chat session restore) run in parallel, followed by permission requests and system UI configuration.

When touching startup code, preserve this "cheap synchronous work only before first frame, everything else deferred" structure — it exists specifically to fix a previously slow/hanging splash screen.

### Dependency injection

`get_it` (`sl` in `lib/utils/di.dart`) is the service locator for repositories, API clients, and a handful of long-lived blocs (`SignInBloc`, `HomeBloc`, `RequestsBloc`, `ApprovalBloc`, etc.), registered as lazy singletons via `initDI()`. Screen/feature-scoped Cubits/Blocs are instead constructed directly and provided in `main.dart`'s root `MultiBlocProvider` (there is a very long, flat list of them — most home-widget cards, HR, Payslip, Performance, Recruitment, and Purchase features each get their own Cubit registered there).

### State management — read this before adding any stateful screen

The codebase is mid-migration across **four** historical patterns: raw `setState`, `provider`/`ChangeNotifier`, `flutter_riverpod`, and GetX. **BLoC/Cubit (`flutter_bloc`) is the current and only standard for new code** — see `docs/BLOC_MIGRATION_ARCHITECTURE.md`. This supersedes the older `docs/adr/0001-state-management.md`, which had picked Riverpod; that ADR is kept for historical context only and should not be followed for new work.

- Provider/ChangeNotifier and GetX markers are fully cleared from `lib`. Riverpod remains in some Timesheet/Site Management call sites and is being migrated feature-by-feature — check `docs/STATE_MANAGEMENT_MIGRATION_STATUS.md` for the current marker counts and what was migrated most recently before picking a "next" feature to touch.
- Non-negotiable migration rules (from `docs/BLOC_MIGRATION_ARCHITECTURE.md`): don't change product behavior, API contracts, Firebase collections, or route names as a side effect of a state-management migration; don't introduce new Provider/Riverpod/GetX state; every migrated feature needs at least a smoke/focused test; use `flutter analyze --no-pub <touched files>` to confirm no regressions in the touched surface before moving on.
- New feature folders should follow: `lib/features/<feature_name>/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,screens,widgets}}`. Most existing code predates this and lives under `lib/ui/presentation/`, `lib/core/<module>/`, or `lib/report_module/` — those legacy locations are fine to keep extending until a feature's full migration happens.
- Avoid touching Timesheet/Site Management, Reports, Chat, or face-recognition/attendance flows for state-management cleanup alone — they're flagged high-risk and are meant to migrate last, in small slices.

### Routing

`lib/routes/app_pages.dart` / `app_routes.dart` are **dead code** — a leftover GetX-generated route table with an empty `routes` list; nothing registers routes there. Actual navigation goes through `lib/utils/generated_routes.dart` (`OnGeneratedRoutes.generatedRoutes`), a large `switch` on route name wired up via `MaterialApp.onGenerateRoute` in `main.dart`. Add new named routes there, not in `app_pages.dart`.

### Logging and code-quality guardrails

- Use `AppLogger` (`lib/core/logging/app_logger.dart`) instead of `print`/`debugPrint` in new or touched code. It auto-redacts sensitive keys (tokens, passwords, device/session IDs) and only emits debug/info logs in debug builds.
- Several tests enforce **budgets, not bans**, on legacy patterns so they can't silently regrow while a full cleanup is still in progress:
  - `test/design/direct_color_budget_test.dart` caps total `Colors.*`/`Color(0x...)` usage outside theme files — put new colors in theme/token files, don't add more direct usage.
  - `test/code_quality/tasks_logging_quality_test.dart` asserts a fixed list of already-cleaned files stay free of `print(` and empty `catch {}` blocks.
  - When adding code, prefer not to move these counters in the wrong direction; if a change legitimately needs to raise a budget, do so deliberately and explain why in the same change.

### Firebase / backend

- `firebase.json` wires two Cloud Functions codebases: `functions` (default — chat notifications, Firebase Admin) and `functions-liveness` (`liveness` codebase — AWS Rekognition face-liveness, credentials passed as Firebase secret params).
- `firestore.rules` are intentionally permissive in several collections (chat messages/members, comments, per-user `todo`/`userChats`) — any signed-in user can read/write paths they don't own in those areas. Don't assume Firestore rules provide authorization; that has to be enforced elsewhere if you're adding sensitive data there.
- Firebase config lives in `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, and `lib/firebase_options.dart` (all generated by `firebase.json`'s `flutter.platforms` block — regenerate with the Firebase CLI rather than hand-editing).

### Local packages

`packages/face_liveness_detector` is a path dependency (`pubspec.yaml`) providing the on-device liveness/anti-spoof plugin used by face-recognition attendance flows. `packages/cunning_document_scanner` is a vendored copy of the document-scanner plugin source (the app actually depends on the hosted `cunning_document_scanner` pub.dev package, per `pubspec.lock`).

### Directory map (`lib/`)

- `core/` — feature-specific business logic and Blocs/Cubits for HR management, timesheet, site management, payslip, performance, recruitment, purchase, biometric/face recognition, security, plus shared services/config/logging/theme/utils used across features.
- `ui/presentation/` — the bulk of screens, organized per feature (attendance, timesheet, purchase_management, hr_management, payslip, performance, recruitment, tasks, todo_list, home_screen, signin, chat-adjacent call_screen, etc.).
- `data/` — cross-cutting models/repositories/services (Hive setup, prayer times, workmanager dispatch, notification services).
- `chat/` — the Firebase-backed chat module (models/repositories/services), separate from `ui/presentation`.
- `report_module/` — the Reports feature, already migrated to a `data/domain/presentation` + `ReportBloc`/`ReportRepository` structure — a reference example for what a fully migrated feature should look like.
- `auth/`, `deep_links/` — UAE PASS auth cubit and deep-link handling (QR survey links, UAE PASS redirect) wired up in `main.dart`.
- `routes/` — dead GetX route stub (see Routing above); real routing is in `utils/generated_routes.dart`.

### Documentation

`doc/` holds product/spec documents (per-module SRDs, API contracts, widget dev plans for the six home-screen widget categories, backend Python API stubs). `docs/` holds engineering/architecture records: state-management ADR and migration log, BLoC migration architecture rules, and a Catch/audit baseline. Check `doc/README.md` for the home-widget-screen plan and `docs/STATE_MANAGEMENT_MIGRATION_STATUS.md` for the latest migration status before starting related work — both are living documents that get updated as work lands, so re-read them rather than relying on a stale summary.

`PROJECT_FULL_AUDIT_REPORT.md` (in Arabic) is a dated full-codebase audit (security, Firebase, code quality, architecture, UI/UX, performance, tests, docs, release readiness, maintainability) with a scorecard and prioritized fixes — useful for understanding known risk areas (broad Firestore rules, large `print`/empty-`catch` counts, heavy direct-color usage, large ML/asset bundle) without re-deriving them from scratch.

## Git workflow

This repo follows GitFlow (`.cursor/rules/gitflow-branching.mdc`): `main` is production (tag releases here), `develop` is integration, feature work happens on `feature/<name>` branched from `develop` and merged back to `develop` (never straight to `main`), `release/<version>` and `hotfix/<version-or-issue>` branches merge to both `main` and `develop`. Confirm the current branch before starting work and don't commit feature work directly to `main`.
