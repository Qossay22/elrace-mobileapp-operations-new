# Project Full Audit Report

Generated at: 2026-07-28 13:40 +04:00  
Project: `elrace-mobileapp-operations-new`  
Source sync target reviewed: `97jaw/Elrace-mobileapp-operations/main`

## Executive Summary

The project has been synced with the latest useful application updates from `Elrace-mobileapp-operations/main` while preserving the cleaner local organization in this repository. The sync added the new feature work, removed stale Dart files left behind by the state-management migration, kept required build files such as the Gradle wrapper, and avoided importing noisy or broken defaults from the source repository.

Current overall project rating: **8.2 / 10**

The app is in a buildable and test-passing state. The remaining risk is mostly quality debt: analyzer warnings, large asset footprint, and Node dependency audit findings in Firebase functions.

## Verification Status

| Check | Result | Notes |
|---|---:|---|
| `flutter pub get` | Pass | Dependencies resolve successfully. |
| `dart analyze --format=machine` | Pass for errors | `ERROR_COUNT=0`; warnings/lints still exist. |
| `flutter test` | Pass | `41/41` tests passed after sync cleanup. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| GitHub push | Pass | `main`, `develop`, and `staging` are pushed to `Qossay22/elrace-mobileapp-operations-new`. |

## Project Inventory

The updated `PROJECT_FILE_INDEX.md` was regenerated on 2026-07-28.

Key counts:

- Indexed files: **2267**
- Indexed total size: **135.69 MB**
- Flutter/Dart files from `rg --files`: **1280**
- Test files: **8**
- Asset files: **527**
- App assets total in file index: **120.02 MB**
- Flutter app code total in file index: **1263 files, 10.23 MB**

## Synced Application Updates

Important updates now present in this repository:

- Chat module updates: restored Discuss shell, groups/files/archive screens, presence-loop fix, new glass UI components, and shared-content tabs.
- Clients and vendors module: clients/vendors dashboards, KPI drill-downs, AR/OI screens, vendor bills, repositories, themes, and list UI.
- My Actions and signatures: signature documents, document viewer, recipient picker, stamp handling, signature repositories, and signature-specific UI.
- Shared Documents and My Documents: shared documents screen, theme, attachment opener, document list tiles, and refreshed document flows.
- Purchase module: provider-based state flow, purchase dev-role toggle, invoice detail sheet, faster filters, and refreshed hub/list screens.
- Home widgets: migration from older Cubit/BLoC widgets toward providers for HRMS, attendance, projects, shared documents, task management, tickets, notes, LPO, petty cash, library, and timesheet widgets.
- Tasks, Todo, QR Survey, and Global Search: provider-based replacements for older bloc files.
- Timesheet and face recognition: enrollment status provider, face match provider, liveness flow updates, face capture service changes, and site report photo page additions.
- Firebase and backend: updated Firestore rules, Firebase functions, liveness functions, and package locks.
- Assets: new business-card visual assets and updated app UI image assets.

## Local Organization Preserved

These choices were intentional to keep this repository cleaner than the source repository:

- Kept `PROJECT_FILE_INDEX.md` and regenerated it.
- Replaced the old full audit report with this updated UTF-8 report.
- Kept Android Gradle wrapper files because they are required for reproducible Android builds.
- Kept project scripts and templates that are useful for maintenance.
- Removed stale Dart files that were no longer referenced after the provider migration:
  - `lib/core/site_management/face_recognition/face_match_session_cubit.dart`
  - `lib/report_module/data/repositories/report_repository.dart`
  - `lib/ui/presentation/home_screen/bloc/home_projects_widgets_cubit.dart`
- Did not import the source repository's default `test/widget_test.dart`, because it was still the Flutter counter test and did not match this app.
- Normalized incorrect executable permissions on assets and Dart files; only real shell scripts keep executable mode.

## Current Risk Review

### Security

Rating: **7.4 / 10**

Strengths:

- Firebase and liveness flows are structured with dedicated function packages.
- Secure storage is used in parts of the chat/auth flow.
- Android backup is disabled in the native manifest.
- Face liveness has local anti-spoof logic plus AWS liveness integration paths.

Risks:

- `npm audit --omit=dev` still reports vulnerabilities:
  - `functions`: 18 total, including 2 critical and 3 high.
  - `functions-liveness`: 12 total, including 1 critical and 1 high.
- Firestore rules should still be reviewed carefully for least-privilege access, especially chat, tasks, user documents, and shared document paths.
- Firebase config files are committed. This is normal for mobile Firebase API keys, but it raises the importance of strong Firestore/Storage rules and App Check.

Recommended next action:

- Upgrade and test Firebase functions dependencies in a separate commit, because some fixes require semver-major upgrades such as `firebase-admin@14.x`.

### Code Quality

Rating: **7.8 / 10**

Strengths:

- The latest sync compiles and tests pass.
- The project has moved many areas from older BLoC/Cubit files to provider-based modules.
- Several large modules now have clearer feature folders: clients/vendors, purchase, signatures, documents, timesheet, and home widgets.

Risks:

- `dart analyze` has zero errors, but still returns warnings/lints. These are not blocking compilation, but they lower maintainability.
- Common warning categories include unused imports, `avoid_print`, deprecated `withOpacity`, `use_build_context_synchronously`, and style/lint issues.
- Some legacy folders and naming conventions remain, including folder names with spaces and mixed case.

Recommended next action:

- Run a focused lint cleanup sprint without changing feature behavior.

### Architecture

Rating: **8.0 / 10**

Strengths:

- The synced code reflects a clearer movement toward providers for app state.
- New modules separate data, screens, widgets, and themes more consistently.
- Stale migration files were removed after confirming they were unused.

Risks:

- The app still mixes Provider, Riverpod, BLoC, Cubit, service locators, and direct services.
- Some legacy module paths remain active, especially around older reports/tasks/project areas.

Recommended next action:

- Document the preferred state-management rule per feature: Provider/Riverpod for new UI state, BLoC only where already stable and useful.

### QA And Release Readiness

Rating: **8.1 / 10**

Strengths:

- `flutter test` passes.
- Debug APK builds successfully.
- The sync was pushed to `main`, `develop`, and `staging`.

Risks:

- Test coverage is still narrow compared with the size of the app.
- No release APK/AAB build was run in this audit.
- No device smoke test was performed after build.

Recommended next action:

- Run one Android device smoke test for login, home, chat, documents, purchase, timesheet capture, and clients/vendors.

### Assets And Performance

Rating: **7.0 / 10**

Strengths:

- Asset index is current.
- New business-card assets are present.
- Generated/heavy folders are ignored correctly.

Risks:

- Assets are still large: **120.02 MB** indexed under assets.
- The project includes ML models, GIFs, Lottie JSON, videos, and many PNG/JPG UI assets.

Recommended next action:

- Audit unused assets and compress large UI images before release.

## Scorecard

| Area | Score |
|---|---:|
| Build health | 9.0 / 10 |
| Tests | 8.0 / 10 |
| Security | 7.4 / 10 |
| Code quality | 7.8 / 10 |
| Architecture | 8.0 / 10 |
| UI/UX organization | 8.0 / 10 |
| Assets/performance | 7.0 / 10 |
| Documentation | 8.5 / 10 |
| Release readiness | 8.1 / 10 |

Overall: **8.2 / 10**

## Immediate Next Steps

1. Fix Firebase functions dependency audit findings in `functions` and `functions-liveness`.
2. Review Firestore and Storage rules against real user roles.
3. Run a release build check with signing configuration available.
4. Do a device smoke test across core workflows.
5. Start a focused lint cleanup pass, especially unused imports and production `print` calls.

## Git State At Audit Time

Latest local/main commits:

- `fe88df2` - Remove stale files after source sync
- `f40d814` - Sync updates from Elrace operations main
- `b7a0842` - Initial project import

Main synced branches:

- `main`
- `develop`
- `staging`
- `sync/source-main-20260728`
