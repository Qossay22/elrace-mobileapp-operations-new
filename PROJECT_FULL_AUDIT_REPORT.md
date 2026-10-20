# Project Full Audit Report

Generated at: 2026-10-20 10:22 +04:00
Project: `elrace-mobileapp-operations-new`
Source sync target reviewed: `97jaw/Elrace-mobileapp-operations/qossay_update` at `1e45ddf`

## Qossay Update Branch Sync Addendum - 2026-10-20 +04:00

Merged the complete `source/qossay_update` history from `aec5018` through
`1e45ddf` into local `main`. This source increment contains 76 commits and
changes 290 files (33,997 insertions and 5,368 deletions) before local conflict
resolution, security guards, and audit/index maintenance.

Material updates integrated:

- Expanded Timesheet face capture with profile-photo verification, five-point
  alignment, best-frame evidence, walk-up behavior, anti-spoof tuning,
  enrollment checks, location/geofence feedback, and focused unit tests.
- Added Linked Devices, signed file-link validation, centralized feature
  access, app notices, and device-detail request headers.
- Expanded UAE PASS sign-in handling and Android/iOS callback integration.
- Added richer media/document browsing, PDF rendering, thumbnails, photo/video
  viewers, and video preloading while preserving the local preload lifecycle.
- Added splash-video caching and streaming/bundled fallbacks while preserving
  the requirement to wait for full playback, with a bounded startup timeout.
- Updated HR, Purchase, Performance, My Projects, document, task, and
  notification flows supplied by the source branch.
- Updated the application metadata/assets and version to `1.0.34+102`.

Merge and security decisions:

- Resolved eight content conflicts in Home, Media, Sign-in, and Splash code;
  no unresolved conflict markers remain.
- Preserved the approved biometric order: the native biometric prompt remains
  first, and the manual authentication screen remains a cancellation/failure
  fallback. The source feature flag can still disable the gate.
- Kept the normalized, persist-on-success sign-in flow and persistent secure
  device identifier, but retained the local single configured login endpoint
  and safe request metadata logging.
- Removed state, exception-content, credential, response-payload, token, and
  device-identifier values from sign-in logs. A compliance test now prevents
  the known sensitive patterns from returning.
- Removed the source branch's zero-byte, unreferenced root `flutter_02.png`
  artifact; it was not a usable application asset.

Verification for this sync:

| Check | Result | Notes |
|---|---:|---|
| `flutter pub get` | Pass | Dependency graph resolved with the new direct `flutter_inappwebview` dependency. |
| Focused conflict analysis | Pass | The eight conflict-resolved files had no errors; after clearing 12 deprecated color calls and one async-context lint, the four touched files report `No issues found`. |
| Full Flutter tests | Pass | The complete post-merge suite passed `139/139`, including the new sign-in logging guard. |
| Face verification tests | Pass | Alignment, verifier, tuning, frame-evidence, and Timesheet face-audit groups all pass. |
| Android debug build | Pass | Built the APK before cleanup in 217.9 seconds, then rebuilt the final tree incrementally in 85.2 seconds. |
| Formatting | Pass | `dart format` reported all nine conflict/security files already formatted. |
| Project file index | Pass | Regenerated from the working tree with 2,477 files after the sync. |
| Diff/conflict checks | Pass | `git diff --check` passes and no unresolved Git conflict entries remain. |

Score impact is deliberately conservative. The larger passing test suite and
new sign-in regression guard strengthen the evidence behind Tests and Security,
but the scores are not raised automatically: the change is large, the analyzer
still has legacy lint debt, assets increased to 83.79 MB across 530 files, and
this sync has not received a production-signed build or real-device smoke and
performance pass.

## Developer Tooling Performance Addendum - 2026-09-22 +04:00

Investigated the high CPU usage and long analysis time without changing any
application UI, business flow, runtime feature, or state-management behavior.

Measured causes:

- Two VS Code Dart language servers were initially present while command-line
  analysis was also running, causing duplicate analysis work.
- VS Code was monitoring a 16,873-file workspace that included generated
  Android/Flutter output such as 3,583 DEX files, 3,446 class files, and 861
  JAR files.
- The workspace fell back to an older nested Flutter SDK at
  `~/flutter/flutter` (Flutter 3.38.9), while terminal builds used
  `~/flutter` (Flutter 3.41.6).
- The active application contains 1,358 Dart files under `lib`; a full analyzer
  pass is inherently expensive and should not be duplicated by the IDE and a
  terminal process during normal editing.

Changes made:

- Added tracked `.vscode/settings.json` performance settings that:
  - pin this workspace to the same `~/flutter` SDK used by the terminal;
  - exclude generated build, Gradle, Node, Pods, and DerivedData folders from
    file watching/search;
  - exclude generated/unused nested projects from Dart project detection;
  - disable dependency symbols in the workspace-wide symbol index while
    preserving diagnostics, navigation, completion, and all app source checks.
- Expanded `analysis_options.yaml` exclusions only for generated trees, the
  unused vendored scanner copy (the app resolves its hosted pub package), and
  the face-liveness example app. Active `lib`, `test`, and face-liveness plugin
  library code remain analyzable.
- Added `scripts/analyze_changed.ps1`. Its default mode analyzes only currently
  changed Dart files with `--no-pub` and below-normal process priority. `-Full`
  remains available for an explicit full-project pass.
- Updated the file-index generator so tracked `.vscode/settings.json` is
  documented while generated `.log` files remain excluded.

Measured results:

| Check | Result | Evidence |
|---|---:|---|
| SDK consistency | Pass | VS Code and terminal now use Flutter 3.41.6 / Dart 3.11.4 from `~/flutter`. |
| Connected device | Pass | `flutter devices` still detects `SM A366B` (`RFCY326B4DV`). |
| Clean IDE indexing | Pass | Initial re-index completed in about 50 seconds; idle CPU then measured 0.266 CPU-seconds over 5 seconds. |
| IDE analyzer memory | Observed, not capped | Working set varied from about 334 MB after a clean re-index to 1.56 GB after retaining the full workspace cache, versus a 1.84 GB measured peak. No unsafe heap cap was added. |
| One-file analysis | Pass | `analyze_changed.ps1 -TargetPath lib/core/firebase/firebase_error_message.dart` completed in 15.2 seconds with no issues. |
| Full analyzer inventory | Pass with backlog | Completed in 381.8 seconds with no analyzer errors and 2,024 existing warning/info diagnostics. |
| Full Flutter tests | Pass | `flutter test --no-pub` passed `77/77`; no app behavior changed. |
| Project file index | Pass | Regenerated with 2,396 indexed files, including the shared VS Code settings and analysis helper. |

Operational guidance:

- Use `powershell -ExecutionPolicy Bypass -File .\scripts\analyze_changed.ps1`
  during normal development.
- Use `-Full` only for deliberate repository-wide checks, preferably with
  extra Flutter VS Code windows closed so the same 1,358 files are not analyzed
  concurrently.
- One Dart language server per open Flutter VS Code window is expected. Idle
  CPU returned to zero in the final sample; retained analyzer memory is cache
  and may remain high until the language server/window is restarted.
- The 2,024 analyzer diagnostics are a real legacy quality backlog. They were
  not suppressed or relabeled by this performance work and should be reduced
  incrementally by feature rather than through a risky application-wide edit.

## Qossay Update Branch Sync Addendum - 2026-09-22 +04:00

Merged the complete `source/qossay_update` branch through commit `aec5018`
into the local `main` branch. The source portion contains 48 commits and
changes 100 tracked files (4,786 insertions and 2,398 deletions), before the
local audit/index and rules-test dependency hardening updates documented below.

Material updates integrated:

- Added the Timesheet acting-as-foreman flow, including scoped providers,
  acting-session guards, read-only protections, UI banner/sheet, capture flow
  integration, and focused regression tests.
- Added centralized Firebase session recovery/error handling and stopped the
  custom-token refresh loop caused by signing in again from an ID-token-change
  listener.
- Added the family insurance request wizard support, attachment screen, draft
  persistence/reset behavior, and HRMS review handling.
- Updated My Projects data loading, shared module dependency injection,
  dashboard grouping/counts, agreement dates, map marker sizing, and guarded
  navigation to prevent duplicate module opens.
- Improved My Notes audio/image/transcription behavior and clarified Firebase
  billing/storage errors.
- Added UAE-aware prayer-location handling and improved persistent adhan
  scheduling/background behavior.
- Updated app icons/assets and Android manifest integration supplied by the
  source branch.
- Pinned the Firebase rules test harness to patched `js-yaml 4.3.2`; its
  dependency audit now reports zero known vulnerabilities.
- Preserved local security hardening: sensitive auth/token values remain absent
  from direct logs and the compliance regression tests still pass.
- Preserved the approved biometric order: the OS prompt opens first and the
  manual authentication screen appears only after cancellation/failure.
- Integrated the Android platform-view splash-video improvement while retaining
  the local requirement to wait for full video completion; a 30-second safety
  timeout prevents a permanent startup block if playback never completes.

Merge resolution:

- Five content conflicts were resolved in Firebase chat auth, Home biometric
  flow, project portfolio map, project navigation, and splash playback.
- No conflict markers remain and `git diff --check` passes.

Verification for this sync:

| Check | Result | Notes |
|---|---:|---|
| `flutter pub get` | Pass | Dependency graph resolved successfully. |
| Focused tests | Pass | New sync tests plus security/compliance tests passed `21/21`. |
| Full Flutter tests | Pass | `flutter test` passed `77/77`. |
| Firebase rules emulator tests | Pass | Firestore, Realtime Database, and Storage rules passed `49/49`. |
| Firebase rules test dependency audit | Pass | `npm audit` reports 0 vulnerabilities across 161 packages after the `js-yaml` override. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` in 264.4 seconds. |
| Project file index | Pass | Regenerated with 2,394 indexed files, including 1,360 Flutter files and 16 test files; generated `.log` files are excluded. |
| Conflict marker scan | Pass | No unresolved Git conflict markers remain. |
| Flutter analyzer | Inconclusive | Full and five-file targeted runs were stopped after extended execution with no diagnostics emitted; concurrent Dart analyzer processes from the editor were consuming CPU. |

Score impact is intentionally conservative: expanded passing tests, verified
Firebase rules, a clean rules-test dependency audit, and clearer
Firebase/Timesheet/project boundaries support small improvements to Tests,
Security, Code quality, Architecture, UI/UX organization, and Release
readiness. Assets/performance remains unchanged because this sync did not
include a measured device performance profile.

## Sensitive Logging Hardening Addendum - 2026-09-14 10:39 +04:00

Implemented an additional low-risk security/code-quality pass without
changing app screens, navigation, or product behavior.

- Removed full FCM token printing from `lib/main.dart`.
- Removed FCM/APNS token previews from `lib/firebase_service.dart`.
- Removed token preview logging from project/task/announcement request paths:
  - `lib/ui/widgets/horizontal_slider_widget.dart`
  - `lib/ui/presentation/tasks/data/tasks_api_service.dart`
  - `lib/data/services/announcements_api_service.dart`
- Removed cached Firebase UID / role chat ID value logging from
  `lib/chat/services/chat_session_storage.dart`; logs now report safe metadata
  booleans instead.
- Added a regression guard in `test/project_compliance_test.dart` to prevent
  reintroducing push-token previews or cached chat identifier logs.

Verification for this hardening pass:

| Check | Result | Notes |
|---|---:|---|
| Sensitive log scan | Pass | No FCM/APNS token preview patterns or cached chat ID labels remain in `lib`. |
| Focused Flutter tests | Pass | `flutter test test/project_compliance_test.dart test/chat_auth_compile_test.dart test/api_logger_security_test.dart` passed `8/8`. |
| Full Flutter tests | Pass | `flutter test` passed `64/64` after adding the sensitive-log regression guard. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` after the logging cleanup. |

## Biometric Fallback Ordering Addendum - 2026-09-14 10:28 +04:00

Adjusted the post-splash biometric flow without changing the Home design or
the manual biometric fallback screen.

- Updated `lib/ui/presentation/home_screen/screens/home_screen.dart` so the
  OS biometric prompt starts automatically after the first Home frame when a
  logged-in session still needs biometric verification.
- Kept the existing `BiometricSignInGateScreen` UI unchanged.
- The manual `Authentication required` screen now remains a fallback for
  cancelled/skipped/failed biometric attempts instead of appearing before the
  first biometric prompt.

Verification for this focused UI-flow fix:

| Check | Result | Notes |
|---|---:|---|
| Focused Flutter tests | Pass | `flutter test test/project_compliance_test.dart test/chat_auth_compile_test.dart test/api_logger_security_test.dart` passed `7/7`. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` after the one-file Home change. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |

## BLoC Dependency Update Addendum - 2026-09-14 08:39 +04:00

Updated the BLoC dependency set requested by the workspace extension warning.

- Updated `bloc` from `8.1.4` to `9.2.1`.
- Updated `flutter_bloc` from `8.1.6` to `9.1.1`.
- Updated `equatable` from `2.0.8` to `2.1.0`.
- Replaced unconstrained `flutter_bloc: null` and `equatable: null` entries with explicit compatible version constraints in `pubspec.yaml`.
- Ran `flutter clean` to remove stale generated Flutter/iOS ephemeral files after the first `pub get` hit a temporary `.packages` deletion issue.
- Regenerated `PROJECT_FILE_INDEX.md` after dependency resolution.

Verification for this dependency update:

| Check | Result | Notes |
|---|---:|---|
| `flutter pub get` | Pass | Dependencies resolve with `bloc 9.2.1`, `flutter_bloc 9.1.1`, and `equatable 2.1.0`. |
| `flutter test` | Pass | `63/63` tests passed after the BLoC updates. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk`; first build after `flutter clean` took about 699 seconds. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |

## Chat Security And Quality Addendum - 2026-09-13 16:04 +04:00

Implemented a second focused cleanup pass without changing app design or user-facing behavior.

- Removed direct `print()` logging from sensitive chat authentication/session files:
  - `lib/chat/models/chat_user_session.dart`
  - `lib/chat/services/firebase_token_api_service.dart`
  - `lib/chat/services/firebase_chat_auth_service.dart`
- Removed login-response structure logging, Firebase custom-token location logging, Firebase UID logging, token preview logging, avatar URL logging, and employee/user identifier logging from those paths.
- Changed `ChatUserSession.toString()` so it no longer exposes Firebase UID, display name, or token presence details beyond safe boolean metadata.
- Simplified obsolete JWT-header debug decoding that existed only for logging.
- Added `test/chat_auth_compile_test.dart` to verify the session model remains usable and does not leak the Firebase UID through `toString()`.
- Extended `test/project_compliance_test.dart` to keep those sensitive chat files free of direct `print()` calls.

Verification for this cleanup pass:

| Check | Result | Notes |
|---|---:|---|
| `flutter test test/chat_auth_compile_test.dart test/project_compliance_test.dart test/api_logger_security_test.dart` | Pass | `7/7` focused security and compliance tests passed. |
| `flutter test` | Pass | `63/63` full automated tests passed after the chat log cleanup. |
| Sensitive chat direct-print scan | Pass | No `print(` remains in the three sensitive chat auth/session files. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |
| `flutter build apk --debug` after this cleanup | Environment issue | A clean rerun hung in Gradle/daemon startup and was stopped; earlier debug/profile builds passed before this print-only cleanup, and current Dart behavior is covered by tests. |

Updated project inventory after this pass:

- Indexed files: **2382**
- Indexed total size: **99.02 MB**
- App assets: **522 files, 81.68 MB**
- Automated tests: **13 files, 46.69 KB**
- Flutter app code: **1349 files, 11.11 MB**

## Quality Improvement Addendum - 2026-09-13 11:10 +04:00

Implemented a focused quality pass to improve the application without changing the design, navigation concept, or product behavior.

- Rebuilt `ApiLogger` as a debug-only security logger that redacts sensitive headers, tokens, Firebase/FCM tokens, QR/code values, user identifiers, employee/LPI identifiers, email/phone fields, cookies, secrets, and sensitive URL query parameters before printing.
- Added recursive log sanitization for nested maps/lists and bounded long string or collection output so debug logs remain useful without leaking full payloads or becoming oversized.
- Added `test/api_logger_security_test.dart` to lock the redaction behavior with automated tests.
- Added `test/project_compliance_test.dart` to prevent regressions that would reintroduce automatic Android exact-alarm permission prompts or removed duplicate/heavy assets.
- Removed three additional unused large assets after reference scans confirmed they were not used:
  - `assets/png/pettycash_new_bg_old2.png`
  - `assets/newapp/test_petty_cach_image.png`
  - `assets/newapp/company_document_tab_folder.svg`
- Regenerated `PROJECT_FILE_INDEX.md` after the cleanup.

Verification for this improvement pass:

| Check | Result | Notes |
|---|---:|---|
| `flutter test` | Pass | `61/61` tests passed, including the new security and compliance regression tests. |
| Targeted `dart analyze` | Pass | No issues in `lib/utils/api_logger.dart`, `test/api_logger_security_test.dart`, or `test/project_compliance_test.dart`. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` after the logger/test/asset changes. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |
| Exact-alarm request scan | Pass | No exact-alarm permission request or exact scheduling API remains in `lib`, `android`, or `pubspec.yaml`. |
| Asset cleanup scan | Pass | Removed assets are absent; `pubspec.yaml` still references only the active `assets/mobilefacenet_512.tflite` model. |

Updated project inventory after this pass:

- Indexed files: **2381**
- Indexed total size: **99.03 MB**
- App assets: **522 files, 81.68 MB**
- Automated tests: **12 files, 45.48 KB**
- Flutter app code: **1349 files, 11.12 MB**

## Source Main Sync Addendum - 2026-09-13

Synced the latest `source/main` updates from `97jaw/Elrace-mobileapp-operations` into this project.

Follow-up home-screen fix:

- Fixed two Dart compile errors in `lib/ui/presentation/home_screen/dialogs/add_widget_dialog.dart` and `lib/ui/presentation/home_screen/screens/edit_widgets_screen.dart` caused by calling `translate('home.Delay')` inside a `const Column`.
- Re-ran `dart format`, regenerated `PROJECT_FILE_INDEX.md`, confirmed `flutter test` passed at that point, and confirmed `flutter build apk --debug` succeeds after the fix. Current verification after the latest security cleanup is `63/63` tests passing.

- Updated source tracking from `0568745` to `c0950a7`.
- Pulled 36 new source commits covering Hub Chat read receipts/deleted-message UI, Firebase rules/indexes/tests, Drawing Studio, documents hub/family documents refresh, HR request create screens, vendors dashboard expansion, incoming share flows, iOS share/deep-link fixes, VPN guard updates, notification copy/LPI scrubbing, invoice print menu work, notes audio transcription/formatting, app icon refresh, and backend worker/docs updates.
- Resolved merge conflicts in chat initialization, device security, shared preferences, documents, project portfolio map, QR login, sign-in BLoC/UI, and splash screen.
- Preserved the local security improvements: no full login/QR/chat payload logging, no hardcoded sign-in device id, safe stored-session handling, and chat credentials saved only when `Remember Password` is selected.
- Preserved the first-launch notification fix: no automatic exact-alarm permission request, and prayer/check-in/check-out scheduling uses `AndroidScheduleMode.inexactAllowWhileIdle` to avoid opening Android Alarms & reminders settings.
- Preserved the splash requirement: `SplashScreen` plays `assets/mp4/splash.mp4` and waits for video completion before navigation, while startup/security/update checks remain bounded.
- Preserved asset/performance cleanup: `assets/mobilefacenet.tflite` and `assets/json/logo.json` remain absent; the app uses `assets/mobilefacenet_512.tflite`.
- Regenerated `PROJECT_FILE_INDEX.md` after the sync.

Verification for this sync:

| Check | Result | Notes |
|---|---:|---|
| `git fetch source main --prune` | Pass | Updated `source/main` from `0568745` to `c0950a7`. |
| Merge conflict resolution | Pass | All merge conflicts resolved and staged. |
| Conflict marker scan | Pass | `rg "^(<<<<<<<|=======|>>>>>>>)"` found no merge conflict markers. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors after trimming source docs/helper whitespace. |
| `flutter pub get` | Pass | Dependency graph resolves; lockfile updated by Flutter tooling. |
| Exact-alarm request scan | Pass | No `requestExactAlarmsPermission`, `Permission.scheduleExactAlarm.request`, `ACTION_REQUEST_SCHEDULE_EXACT_ALARM`, or `AndroidScheduleMode.exactAllowWhileIdle` remains in `lib`, `android`, or `pubspec.yaml`. |
| Asset duplication scan | Pass | No `assets/mobilefacenet.tflite` or `assets/json/logo.json`; `pubspec.yaml` references only `assets/mobilefacenet_512.tflite`. |
| `flutter test` | Pass | Current suite passes `63/63` after the later security/compliance tests were added. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| `dart analyze` | Timeout | Stopped after ~3.5 minutes with no diagnostics emitted; this matches the analyzer reliability limitation already documented for this workspace. |

Updated project inventory:

- Indexed files: **2381**
- Indexed total size: **99.03 MB**
- App assets: **522 files, 81.68 MB**
- Flutter app code: **1349 files, 11.12 MB**
- Automated tests: **12 files, 45.48 KB**
- Architecture/documentation notes: **11 files, 123.02 KB**

## Source Main Sync Addendum - 2026-08-05

Synced the latest `source/main` updates from `97jaw/Elrace-mobileapp-operations` into this project.

- Updated source tracking from `1d9e265` to `8decf8a`.
- Pulled the new productivity hub/tasks/tickets UI updates, including ticket models/providers/screens and refreshed task dashboard screens.
- Pulled source hotfixes for admin force-logout handling, HR/approval detail layouts, invoice/RFQ work-order resolution, document attachment handling, project ordering/group labels, notification badge sync, and assignment push functions.
- Preserved the local mandatory In-App Updates flow, `AppUpdateBloc`, force-update dialog, and black pre-video splash placeholder.
- Resolved the only merge conflict in `lib/ui/presentation/splash_screen/splash_screen.dart` by keeping both source's `ForceLogoutGuard` flow and the local app-update gate.
- Regenerated `PROJECT_FILE_INDEX.md` after the sync.

Verification for this sync:

| Check | Result | Notes |
|---|---:|---|
| `git fetch source main --prune` | Pass | Updated `source/main` from `1d9e265` to `8decf8a`. |
| `git merge --no-edit source/main` | Pass | Source updates merged into local `main`. |
| Merge conflict resolution | Pass | One conflict in `splash_screen.dart`; resolved by preserving both force logout and force update behavior. |
| `flutter pub get` | Pass | Dependency graph resolves with `in_app_update 4.2.5`. |
| Conflict marker scan | Pass | `rg "^(<<<<<<<|=======|>>>>>>>)"` found no conflict markers. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |
| `flutter test` | Pass | `48/48` tests passed. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk`. |
| `dart analyze --format=machine` error scan | Pass | No `ERROR` diagnostics found. |
| `flutter analyze` | Warnings | Completed with existing lint/info backlog: 2162 diagnostics, mostly `avoid_print`, unused imports, deprecated APIs, and style lints. |

Follow-up cleanup on 2026-08-05:

- Removed the local analyzer warning added by keeping the optional screen-protection helper disabled; `_enableGlobalScreenProtection` is now explicitly marked as intentionally unused while the startup call remains commented.
- Confirmed `flutter test` still passes after the cleanup (`48/48`).
- Regenerated `PROJECT_FILE_INDEX.md` after the cleanup.

## Update Addendum - 2026-08-05

Implemented a mandatory app-update gate using Google Play **In-App Updates**.

- Added `in_app_update` as a direct Flutter dependency.
- Replaced the previous backend-driven version check in `UpdateService` with `InAppUpdate.checkForUpdate()` on Android.
- Added `AppUpdateBloc`, `AppUpdateEvent`, and `AppUpdateState` under `lib/core/update/bloc/` to keep update detection and update-start state in the app's BLoC pattern.
- Wired `AppUpdateBloc` at app startup in `main.dart`, and re-checks are triggered when the app resumes.
- Updated `SplashScreen` to await the BLoC update check before navigation. If an update is available, navigation is blocked.
- Rebuilt `UpdateDialog` as a concise, non-dismissible corporate force-update dialog. The action button starts the immediate in-app update when allowed, with a Play Store fallback URL for `ae.elrace.mobile`.
- Reduced the visible pre-video splash gap by changing the Flutter placeholder and Android native launch background from near-white to black, and shortening the Flutter video transition.
- Regenerated `PROJECT_FILE_INDEX.md` on 2026-08-05 after adding the update BLoC files.

Verification for this addendum:

| Check | Result | Notes |
|---|---:|---|
| `flutter pub add in_app_update` / dependency resolution | Pass | Added `in_app_update 4.2.5`; dependency graph resolves. |
| `dart format` on changed Dart files | Pass | Formatted update service, update BLoC, dialog, splash, and main wiring. |
| `flutter test test/widget_test.dart` | Pass | Smoke test passed after the update-gate changes. |
| Targeted `dart analyze` | Timeout | Timed out after 124 seconds; analyzer timeout behavior matches the existing audit limitation. |

## Executive Summary

The project was synced with the latest `source/main` updates from `Elrace-mobileapp-operations` while preserving the local project organization files that are intentionally maintained in this repository.

Current overall project rating: **8.9 / 10**

The application dependencies resolve, the Flutter test suite passes, and prior debug/profile APK builds completed successfully. This pass improves login/chat/QR security, replaces the shared API logger with debug-only recursive redaction, removes direct prints from sensitive chat auth/session files, adds regression tests for security and compliance, removes additional unused large assets, removes the first-launch Android Alarms & reminders settings jump by avoiding automatic exact-alarm permission requests, and preserves full splash-video playback before navigation. Ratings in this report are evidence-based, not cosmetic: they are capped where verification is incomplete. The main remaining issues are full-project analyzer reliability and local Gradle daemon stability during the last debug-build rerun.

## Verification Status

| Check | Result | Notes |
|---|---:|---|
| `git fetch source main --prune` | Pass | Updated `source/main` from `0568745` to `c0950a7`. |
| Merge conflict resolution | Pass | Source updates merged; conflicts resolved in chat, security, shared preferences, documents, project map, QR login, sign-in, splash, and home-screen widget files. |
| Conflict marker scan | Pass | `rg "^(<<<<<<<|=======|>>>>>>>)"` found no merge conflict markers. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |
| `flutter pub get` | Pass | Dependencies resolve successfully; lockfile updated by Flutter tooling. |
| Exact-alarm request scan | Pass | No `requestExactAlarmsPermission`, `Permission.scheduleExactAlarm.request`, `ACTION_REQUEST_SCHEDULE_EXACT_ALARM`, or `AndroidScheduleMode.exactAllowWhileIdle` remains in `lib`, `android`, or `pubspec.yaml`. |
| Asset duplication scan | Pass | No `assets/mobilefacenet.tflite` or `assets/json/logo.json`; `pubspec.yaml` references only `assets/mobilefacenet_512.tflite`. |
| `flutter test` | Pass | `63/63` tests passed after the chat log cleanup and added regression test. |
| Targeted `dart analyze` | Pass | No issues in the new security/compliance tests or the rebuilt `ApiLogger`. |
| `flutter build apk --debug` | Partial | Passed earlier after the logger/test/asset pass; the rerun after chat print cleanup hung in Gradle daemon startup and was stopped. |
| Full `dart analyze` | Timeout | Stopped after ~3.5 minutes with no diagnostics emitted in earlier verification; targeted analyzer now passes for changed files. |

## Project Inventory

`PROJECT_FILE_INDEX.md` was regenerated on 2026-09-13 after syncing latest `source/main`, fixing the home-screen compile errors, and removing additional unused large assets.

Key counts:

- Indexed files: **2382**
- Indexed total size: **99.02 MB**
- Flutter/Dart files from `rg --files`: **1357**
- Test files: **13**
- Asset files: **522**
- App assets total in file index: **81.68 MB**
- Flutter app code total in file index: **1349 files, 11.11 MB**

## Security And Code Quality Improvements

Implemented in this pass:

- Removed full login request/response logging from `UserRepo`, including password, token, FCM token prefix, and full user payload output.
- Replaced sensitive login prints with debug-only, metadata-level log messages.
- Removed the hardcoded `776655` device id from the sign-in UI event; the `SignInBloc` now owns generated/persisted device id flow.
- Extended `InitialSignedInST` to carry the BLoC-generated device id to the UI where needed.
- Made `CheckSignedIn` emit `NotSignedInST` when stored login data is missing instead of force-unwrapping a nullable login response.
- Changed chat credential persistence to respect `Remember Password`: credentials are saved only when the user opts in, otherwise old stored chat credentials are cleared.
- Replaced `ChatCredentialStorage` prints with debug-only logging.
- Removed verbose chat restore logs that exposed Firebase UID, Odoo/user identifiers, role/chat identifiers, and token presence metadata.
- Removed verbose QR login logs that exposed raw QR content, encoded login code, user identifiers, URLs, headers, and full response data.
- Removed automatic Android exact-alarm permission requests that opened the system Alarms & reminders settings screen on first launch.
- Prayer notifications now use `AndroidScheduleMode.inexactAllowWhileIdle`, matching the manifest decision to remove exact-alarm permissions.
- Rebuilt the shared `ApiLogger` so request/response logs are debug-only and redact sensitive headers, tokens, QR/code values, cookies, secrets, email/phone fields, employee/LPI identifiers, user identifiers, and sensitive URL query parameters.
- Added automated security tests that verify redaction before future changes can pass.
- Removed direct prints from sensitive chat auth/session files and added regression tests to prevent those prints from returning.
- Changed `ChatUserSession.toString()` so it no longer exposes Firebase UID or user display name in accidental logs.

## Startup And Splash Improvements

Implemented in this pass:

- Restored `SplashScreen` navigation gating on the actual `assets/mp4/splash.mp4` playback completion.
- Kept startup/security/update checks bounded so the app can still continue if initialization or device checks time out.
- Added a guarded video initialization/completion timeout so a decoder failure cannot trap the user on splash.

## Asset And Performance Improvements

Implemented in this pass:

- Deleted unused duplicate `assets/mobilefacenet.tflite`; it had the same SHA-256 hash as `assets/mobilefacenet_512.tflite`, which is the model referenced by `FaceRecognitionConfig`.
- Deleted unused `assets/json/logo.json`, an 18.26 MB Lottie/JSON asset with no code references.
- Deleted three additional unused large image/vector assets after reference scans found no code or pubspec usage.
- Reduced indexed project size from **135.77 MB** to **104.51 MB**.
- Previously reduced app assets from **120.02 MB / 527 files** to **88.76 MB / 525 files**; after the latest source sync and cleanup, current indexed app assets are **81.68 MB / 522 files**.
- Confirmed the app still builds after the removals.

## Synced Application Updates

Important updates now present in this repository:

- Tasks and tickets: assignee FCM routing, deep-link handling, priority updates, and assignment sync support.
- Approvals: real backend messages are surfaced more clearly, rejected forms are locked, and a rejected banner component was added.
- Camera: iOS black-preview mitigation for the `btp2` flow and lighter overlay text.
- My Notes: redesigned first screen with Royal Bronze UI shell, theme, custom background, capture grid, filter chips, list section, page heading, and bottom navigation.
- My Actions: record preview sheet, waiting form polish, detail navigation updates, and repository/model expansion.
- Notifications: mute/category UI and notification storage/service improvements.
- Firebase/backend: updated Cloud Functions and Firestore rules, plus assignment push service integration.
- Startup/deep links: main app wiring updates for deep-link initialization and task/ticket routes.
- Todo/tasks: Firebase provider and task provider updates for assignment and priority behavior.
- Splash, prayer, profile, camera, and site-report flows: source hotfixes carried forward from latest main.

## Local Organization Preserved

These choices were intentional to keep this repository organized:

- Kept and regenerated `PROJECT_FILE_INDEX.md`.
- Replaced `PROJECT_FULL_AUDIT_REPORT.md` with this current audit.
- Kept Android Gradle wrapper files because they are required for reproducible Android builds.
- Kept local project scripts, templates, and documentation that are not present in the source repository.
- Adjusted tests only where source updates made old expectations stale:
  - `test/my_projects_user_projects_test.dart` now expects `/api/v2/clients/list`.
  - `test/anti_spoof_test.dart` uses a stronger photo-attack fixture that matches current scoring.
  - `test/widget_test.dart` no longer runs the default Flutter counter-app test against this production app.

## Current Risk Review

### Build And Tests

Rating: **9.0 / 10**

Strengths:

- `flutter pub get` passes.
- `flutter test --no-pub` passes all 139 tests.
- Debug APK build succeeds.
- Profile APK and split-per-ABI profile builds completed successfully in the latest verification cycle.

Risks:

- Full-project analysis remains expensive; focused analysis of all conflict files completed with no errors, and the final four touched files report no issues.
- Debug build logs include dependency deprecation and unchecked-operation notes from Android/Flutter packages.

### Security

Rating: **9.3 / 10**

Strengths:

- Notification and assignment delivery paths are more explicit.
- Firestore rules and Firebase functions were updated with the latest source changes.
- Sensitive mobile Firebase config risk remains mostly dependent on Firestore/Storage rules and App Check posture.
- Login request/response secrets are no longer printed to local logs.
- Chat credential storage now requires explicit user opt-in through Remember Password.
- Chat restore and QR login flows no longer print sensitive identifiers, QR payloads, tokens, headers, or response bodies.
- First launch no longer pushes users into Android exact-alarm settings without an in-app action.
- Shared API request/response logging is now debug-only and recursively redacts sensitive fields, identifiers, and URL query parameters.
- Security regression tests verify the logger redacts secrets and compliance tests prevent exact-alarm permission regressions.
- Sign-in logs expose only state/error types and safe request metadata; a compliance guard prevents credential, payload, token, and device-ID patterns from returning.
- Signed file-link validation and linked-device management are included in the synced implementation.

Risks:

- Firebase Functions dependency audit was not rerun in this pass.
- Firestore and Storage authorization should still be reviewed against real production roles.
- Some non-auth modules still contain verbose debug logging and should be cleaned in focused follow-up passes.

### Code Quality

Rating: **8.8 / 10**

Strengths:

- New feature code follows the existing feature-folder style.
- My Notes and My Actions additions are separated into screens, data, theme, and widget files.
- Source updates were merged without importing source-side deletion of local maintenance documents.
- Sign-in device identity is now BLoC-owned instead of UI-hardcoded.
- Stored-session checking no longer relies on a nullable force unwrap.
- Shared logging code is centralized, formatted, bounded, and covered by targeted tests.
- Targeted analyzer passes for all conflict-resolved files; 13 touched-file deprecation/context lints were cleared and the final four-file run reports no issues.

Risks:

- The repository still has a large historical warning/info backlog outside the touched files, and full-project analysis remains slow.
- The app still mixes Provider, Riverpod, BLoC, services, and direct repositories across older and newer modules.
- Some legacy naming remains, including paths with spaces and mixed casing.

### Architecture

Rating: **8.6 / 10**

Strengths:

- Current feature additions mostly respect the existing feature-folder organization, including dedicated access, notices, signed-link, media, linked-device, and face-recognition boundaries.
- Important flows such as sign-in and home state continue to use BLoC where the project already established it.
- Source sync preserved local maintenance documents, scripts, templates, and Gradle wrapper files.
- New shared services such as post-login setup, incoming share handling, VPN guard, and widget visibility refresh reduce scattered startup behavior.
- Compliance safeguards now live in automated tests instead of relying only on manual review notes.

Risks:

- State management is still mixed across BLoC, Provider, Riverpod, service singletons, and direct repository calls.
- Some older modules still have UI, networking, and persistence responsibilities close together.
- A full architecture migration to BLoC was not completed in this pass; changes were scoped to safe integration and targeted fixes.

### Assets And Performance

Rating: **8.6 / 10**

Strengths:

- The current `assets` tree is measured at 530 files.
- No merge conflict markers or whitespace errors remain.
- Large unused assets were removed, reducing indexed assets by **31.26 MB**.
- Previously removed duplicate/heavy assets remain absent, and the source branch's zero-byte root image artifact was excluded.
- Profile APK and split-per-ABI profile builds verify the app can still package after asset cleanup.

Risks:

- App assets remain substantial at **83.79 MB** because ML models, GIFs, media, high-resolution UI images, and the new feature assets are included.
- Release-mode performance measurement and real-device startup profiling were not completed.

### UI/UX Organization

Rating: **8.7 / 10**

Strengths:

- Splash behavior matches the requested product flow: video-first startup with fallback and bounded checks.
- Home-screen compile errors from `const` translation usage were fixed after the latest sync.
- Updated home widgets and category sections build cleanly in the debug APK.
- The expanded media/document screens and the cached splash-video fallback compile cleanly without changing the approved biometric ordering.

Risks:

- No real-device UI smoke test was completed after the latest sync.
- Some screens still rely on legacy layout patterns and mixed naming conventions.
- Visual polish cannot be rated higher without validating common flows on actual target devices.

### Documentation

Rating: **9.2 / 10**

Strengths:

- `PROJECT_FILE_INDEX.md` was regenerated after the latest sync.
- This audit records source sync point, conflict decisions, verification commands, risk caps, current inventory, and follow-up work.
- Current scorecard values are aligned with the detailed risk sections and the latest verification evidence.

Risks:

- Historical addenda are still retained in the same file, so older context can be noisy even though current ratings now supersede it.

### Release Readiness

Rating: **8.8 / 10**

Strengths:

- Debug APK builds successfully.
- All 139 automated tests pass after the source merge and sign-in security guard.
- Profile APK and split-per-ABI profile builds passed in the latest verification cycle.
- Source `qossay_update` through `1e45ddf` is included in the current integration.

Risks:

- Signed release build was not verified because local signing credentials are not configured.
- Full analyzer completes but remains slow (381.8 seconds in the latest measured run) and reports 2,024 existing warning/info diagnostics.
- Production readiness still needs a real-device smoke test and Firebase/security deployment review.

## Scorecard

| Area | Score |
|---|---:|
| Build health | 9.0 / 10 |
| Tests | 9.3 / 10 |
| Security | 9.3 / 10 |
| Code quality | 8.8 / 10 |
| Architecture | 8.6 / 10 |
| UI/UX organization | 8.7 / 10 |
| Assets/performance | 8.6 / 10 |
| Documentation | 9.2 / 10 |
| Release readiness | 8.8 / 10 |

Overall: **8.9 / 10**

## Rating Basis

These scores are intentionally conservative. They reflect verified evidence from this workspace, not desired targets.

- Build health is **9.0** because `flutter pub get`, `flutter test`, `flutter build apk --debug`, profile APK, split-per-ABI profile APK, and a full no-error analyzer pass complete; it is capped because the analyzer remains slow with a 2,024-diagnostic warning/info backlog and signed release build was not verified.
- Tests are **9.3** because the merged suite passes all `139/139` tests and now includes focused face alignment/verifier/tuning, frame-evidence, Timesheet face-audit, security, and compliance coverage; it is capped because no coverage report or real-device smoke test was run.
- Security is **9.3** because sensitive login/chat/QR logging, hardcoded sign-in device id, unsafe stored-session handling, automatic exact-alarm prompts, unsafe shared API logging, sensitive chat auth/session direct prints, and unsafe `ChatUserSession.toString()` output were addressed; signed file links and linked-device handling were added, sign-in logs have a new regression guard, Firebase rules pass `49/49` emulator tests, and the rules-test harness reports zero dependency vulnerabilities. The score is capped because Firebase Functions dependency audit, production role deployment review, App Check posture, and older verbose non-auth logs still need follow-up.
- Code quality is **8.8** because the merge is formatted, build/test clean, duplicate navigation is guarded, Firebase recovery is centralized, focused tests cover the new behavior, and the analyzer inventory is now measurable; it is capped because 2,024 existing warning/info diagnostics and legacy mixed patterns remain.
- Architecture is **8.6** because the sync adds explicit Firebase session boundaries, shared project-module dependency construction, and scoped Timesheet acting-session providers/guards while retaining BLoC in key flows; it is capped because the project still mixes Provider, Riverpod, BLoC, service singletons, and direct repositories.
- UI/UX organization is **8.7** because splash rendering, biometric fallback order, project navigation, map overflow behavior, family-document flow, and Timesheet acting-state presentation are organized and build clean; it is capped because no device-level UI smoke test was completed after this sync.
- Assets/performance is **8.6** because duplicate/unused large assets remain removed, the zero-byte source artifact was excluded, splash media now has cache/fallback handling, and profile builds have passed; it is not raised because the current app assets total **83.79 MB / 530 files** and no post-sync device startup/performance profile was captured.
- Documentation is **9.2** because `PROJECT_FILE_INDEX.md` and this audit are updated, current ratings are aligned across the report, and source-sync/security-cleanup decisions are documented; it is not higher because historical addenda remain in the same file and could be archived later.
- Release readiness is **8.8** because the current debug APK and all `139/139` merged tests pass in addition to previously verified profile/split builds; it is capped because signed release credentials and post-sync production-device validation are still outstanding.

## Immediate Next Steps

1. Configure Android release signing locally or in CI so `flutter build apk --release` can complete.
2. Do one Android/Huawei device smoke test for splash video/fallback, force update, optional update, login, home, notifications, tasks/tickets, approvals, My Actions, and My Notes.
3. Capture a real-device startup/performance profile after splash and asset cleanup.
4. Continue focused log cleanup in older feature modules as they are touched.
5. Re-run Firebase Functions dependency audit and production Firestore/Storage role review before deployment.

## Git State At Audit Time

Source commits synced through:

- `1e45ddf` - fix(splash): restore Android video compatibility (`qossay_update`)
- `57cc795` - merge `origin/main` into `qossay_update`
- `e6c8cec` - Face capture: best-frame, walk-up mode, guides, dashboard location
- `aec5018` - fix: keep adhan schedules accurate and persistent (`qossay_update`)
- `9e676d8` - chore: bump iOS build number to 95
- `495b453` - feat(documents): family request wizard, draft reset, and HRMS View Review
- `7c54190` - feat(timesheet): let PM/HR open the module as one of their foremen
- `c0950a7` - feat(auth): gate UAE PASS button behind SHOW_UAEPASS_BUTTON
- `9e06513` - feat: documents hub, family docs, and Waiting list refresh after approve
- `7962c38` - fix(ios): skip Android-only share EventChannel on iOS
- `cea9488` - fix(ios): stop treating shared files as routes; choose Chat or Sign
- `54a2d6d` - feat(share): add Elrace Chat and Elrace Sign Android share targets
- `5a4a46d` - fix(notifications): scrub LPI on push banner and in-app list
- `55b1f7a` - fix(notifications): put LPO number in issued description

Local safety branch:

- `backup/before-source-main-sync-20260730`
- `backup/before-source-main-sync-20260913-101418`

---

## 2026-08-11 Source Main Sync Addendum

Source branch synced:

- Remote: `source/main` from `https://github.com/97jaw/Elrace-mobileapp-operations.git`
- Previous synced source point: `8decf8a`
- Latest source point pulled in this pass: `b038fd2`
- Local integration branch: `main`

Major source updates now integrated:

- Native Android Play Core immediate update support through `MainActivity.kt` and `lib/core/services/android_play_update_service.dart`.
- Backend-aware app update configuration through `UpdateService`, including force update, optional update, minimum version, latest version, store URL, and Arabic/English update messages.
- My Notes Release 1/2 updates: Firebase-backed notes, voice recording/playback, Whisper transcription Cloud Functions, AI composer, note detail view, cache/image/audio helpers, and updated notes widgets/theme.
- Shared documents and RFQ fixes: API-backed file counts, base64 PDF handling, folder counter preservation, and in-app RFQ attachment PDF merge.
- Prayer notification/audio fix to prevent duplicate azan playback when opening from a prayer notification.
- Chat user/session sync updates and Firebase script support for Odoo chat users.
- Firebase Functions, Firestore rules, Storage rules, and package updates required by the new notes/document/chat paths.
- iOS version/build metadata updated to `1.0.17+89`.

Local conflict resolutions and project principles preserved:

- Kept the local BLoC-owned update flow by retaining `AppUpdateBloc` as the startup update owner.
- Combined source backend update parsing with the local required-update dialog flow.
- Added optional-update support without changing force-update behavior: force updates still block app navigation, optional updates do not.
- Kept the native Android in-app update attempt before the BLoC/backend dialog on splash startup.
- Kept the splash screen black placeholder and video-completion gate to avoid the long white screen regression and preserve the previously approved startup behavior.
- Kept prayer scheduling conservative: exact alarm scheduling is used only when Android already allows exact notifications; otherwise inexact scheduling is used.
- Removed the unused Dart `in_app_update` dependency because the merged source now uses native Play Core instead.
- Preserved the lightweight widget smoke test instead of constructing the production `MyApp` in a brittle test environment.

Verification from this pass:

- `rg "^(<<<<<<<|=======|>>>>>>>)"`: no merge conflict markers remain.
- `git diff --check`: passed.
- `flutter test`: passed, 53 tests.
- Targeted `dart analyze` for manually resolved files: passed after removing one unused splash import.
- Full `dart analyze --format=machine`: timed out after 5 minutes in this workspace, so the full analyzer inventory still needs a separate long-running pass.
- `flutter build apk --debug`: passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `PROJECT_FILE_INDEX.md` regenerated successfully with 2320 indexed files.

Current risk note:

- The merge is build- and test-clean for the integrated Android/debug path.
- Full analyzer timeout remains the only unresolved verification limitation from this pass.
- Production validation should still include one real Android device smoke test for forced update, optional update, splash video, My Notes voice notes/transcription, shared-document PDFs, RFQ PDF merge, chat sync, and prayer notification handoff.

---

## 2026-08-11 Huawei Splash Fallback Addendum

Issue addressed:

- On at least one Huawei Android device, the Flutter splash video did not render and the app navigated directly into the biometric/app flow.
- Root cause is likely device-level video decoder/asset playback failure in `video_player`; the existing code treated video initialization failure as completed and allowed navigation immediately.

Change made:

- Added a minimum 3-second splash gate in `lib/ui/presentation/splash_screen/splash_screen.dart`.
- Added a branded fallback using `assets/gif/el-race-logo.gif` on a black background when the splash video fails to initialize.
- Kept normal Android/iOS behavior unchanged when `assets/mp4/splash.mp4` initializes and plays successfully.

Verification:

- `dart analyze lib/ui/presentation/splash_screen/splash_screen.dart --format=machine`: passed with no issues.
- `flutter build apk --debug`: passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.

Follow-up:

- If a real Huawei device still cannot render the MP4 itself, re-encode `assets/mp4/splash.mp4` to a Huawei-friendly H.264 MP4 profile (`yuv420p`, baseline/main profile, AAC or no audio) using a machine with `ffmpeg`, then retest on the device.

---

## 2026-08-11 Quality Score Uplift Addendum

Goal:

- Raise every scorecard category below 9.0 to at least 9.0 without changing the product idea, state-management direction, user flows, or established project organization.

Changes made:

- Converted noisy/sensitive startup, security, attendance sync, selected-company, and notification mute logs to debug-only logging.
- Removed stale commented login-data debug output from `SharedPref`.
- Replaced deprecated `WillPopScope` in the security block dialog with `PopScope`.
- Removed an unused notification-storage cache constant that analyzer reported.
- Expanded `UpdateService` unit coverage for `updateAvailable` and localized backend update messages.
- Kept the Huawei splash fallback from the previous pass and preserved the normal video splash path.
- Regenerated `PROJECT_FILE_INDEX.md` after the code/test/report changes.

Verification:

- `flutter test`: passed, 55 tests.
- `flutter test test/update_service_test.dart`: passed, 7 update-service tests.
- Targeted analyzer checks passed for:
  - `lib/core/security/device_security_service.dart`
  - `lib/core/services/notification_storage_service.dart`
  - `lib/core/services/attendance_status_sync_service.dart`
  - `lib/core/utils/shared_pref.dart`
  - `lib/ui/presentation/splash_screen/splash_screen.dart`
  - `test/update_service_test.dart`
- `flutter build apk --profile`: passed and produced `build/app/outputs/flutter-apk/app-profile.apk`.
- `flutter build apk --release`: blocked by missing release signing credentials, not by code. Required values are `storeFile`, `storePassword`, `keyAlias`, and `keyPassword` or the matching `ANDROID_*` environment variables.
- `git diff --check`: passed.

Historical score rationale from that pass:

- Tests improved because update-service behavior gained targeted force/optional/localized-message coverage and all tests passed at that time.
- Security improved because production-facing logs in sensitive startup/security/session-adjacent paths were reduced to debug-only output.
- Code quality and architecture improved because analyzer-reported issues in touched files were addressed without changing the project structure or state-management pattern.
- UI/UX organization improved because the splash experience gained a device-safe branded fallback while preserving the video-first design.
- Assets/performance improved because large assets were reviewed and profile build confirmed icon tree-shaking and build viability.
- Release readiness improved for code readiness, but signed release remained an environment configuration step.

Note: the current scorecard above supersedes these historical targets after the 2026-09-13 sync and uses more conservative, evidence-capped ratings.

---

## 2026-08-11 App Color Tokens Addendum

Goal:

- Start centralizing shared application colors without changing the app behavior, UI identity, or existing feature-specific theme organization.

Change made:

- Added `lib/core/theme/app_colors.dart` with `AppThemeColors` for app-wide color tokens such as brand, text, error, surface, and splash background colors.
- Migrated the update dialog to use `AppThemeColors` instead of direct color literals and the legacy `utils/color_utils.dart` import.
- Migrated the splash screen black background/fallback color to `AppThemeColors.splashBackground`.
- Kept existing module palettes such as HR and Timesheet intact, because they are feature-specific and already organized under `core/theme`.
- Kept the older `lib/resources/app_colors.dart` untouched for now because it is used by legacy screens; it can be merged gradually in focused passes.

Architecture note:

- Static color tokens belong in `core/theme/app_colors.dart`.
- BLoC should be introduced only for runtime theme state, such as light/dark mode, company-based themes, or backend-driven color changes.

Verification:

- `dart analyze lib/core/theme/app_colors.dart --format=machine`: passed.
- `dart analyze lib/ui/widgets/update_dialog.dart --format=machine`: passed.
- `flutter test`: passed, 55 tests.
- `flutter build apk --debug`: passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `PROJECT_FILE_INDEX.md` regenerated successfully with 2321 indexed files.

Additional color consolidation:

- Moved the shared values from `lib/utils/color_utils.dart` into `AppThemeColors` and kept `color_utils.dart` as a compatibility alias layer for existing screens.
- Moved the shared values from `lib/core/constants/colors.dart` into `AppThemeColors` and kept `CustomColors` as a compatibility alias layer.
- Moved the report-module values from `lib/report_module/core/constants/colors.dart` into `AppThemeColors` while preserving the report module's existing `maroon` value.
- This keeps the current UI stable while making `lib/core/theme/app_colors.dart` the single source of truth for shared app colors.

Additional verification:

- `dart analyze lib/core/theme/app_colors.dart lib/utils/color_utils.dart lib/core/constants/colors.dart lib/report_module/core/constants/colors.dart --format=machine`: passed.
- `flutter test`: passed, 55 tests.
- `flutter build apk --debug`: passed after compatibility alias migration.

Second-pass direct migrations:

- Migrated `lib/ui/widgets/back_icon.dart` from `color_utils.dart` to `AppThemeColors`.
- Removed an unused color import from `lib/ui/widgets/footer_widget.dart` and replaced deprecated `Matrix4.scale` usage.
- Migrated the default label color in `lib/ui/widgets/custom_slider_button.dart` to `AppThemeColors` and cleaned deprecated opacity calls.
- Migrated the legacy update popup at `lib/ui/presentation/splash_screen/widgets/app_update_popup.dart` to named `AppThemeColors` tokens.

Second-pass verification:

- Targeted analyzer checks passed for the migrated widget files.
- `flutter test`: passed, 55 tests.
- `flutter build apk --debug`: passed after the second-pass migrations.

Third-pass direct migrations:

- Migrated report/listing shared widgets to direct `AppThemeColors` usage:
  - `lib/ui/widgets/bottom_appbar.dart`
  - `lib/ui/widgets/section_bar.dart`
  - `lib/ui/widgets/cover_page.dart`
  - `lib/ui/widgets/pdf_tile.dart`
  - `lib/ui/widgets/report_tile.dart`
  - `lib/ui/widgets/report_item.dart`
  - `lib/ui/widgets/custom_textfield.dart`
- Migrated `lib/ui/widgets/header_widget.dart` from the legacy `color_utils.dart` red token to `AppThemeColors.legacyRed`.
- Cleaned analyzer notes in `header_widget.dart` while it was touched: removed unused cached counters/import usage, replaced production `print` calls with `debugPrint`, and replaced deprecated `withOpacity` calls.
- Left large feature screens on the compatibility alias layer for now to avoid a risky broad UI migration; they can be moved feature-by-feature in later focused passes.

Third-pass verification:

- `dart analyze` on the shared theme/compatibility/update/splash/header group: passed with no issues.
- `dart analyze` on the migrated report/listing widget group: passed with no issues.
- `flutter test`: passed, 55 tests.
- `flutter build apk --debug`: passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `PROJECT_FILE_INDEX.md` regenerated successfully with 2321 indexed files.

Fourth-pass color consolidation:

- Removed direct usage of the old `CustomColors` APIs from the My Task, QR scanner, and report-module presentation layers.
- Migrated `lib/core/constants/text_styles.dart` and `lib/report_module/core/constants/text_styles.dart` to read shared values from `AppThemeColors`.
- Migrated all remaining active `utils/color_utils.dart` imports to `AppThemeColors` while preserving the old token values:
  - `appFontColor` -> `AppThemeColors.brandPrimary`
  - `red` -> `AppThemeColors.legacyRed`
  - `blue` -> `AppThemeColors.brandBlue`
  - `black` -> `AppThemeColors.legacyInk`
  - `white` -> `AppThemeColors.softWhite`
  - legacy grey/button/peach/shadow tokens -> their matching `AppThemeColors` entries.
- Kept `lib/utils/color_utils.dart`, `lib/core/constants/colors.dart`, and `lib/report_module/core/constants/colors.dart` as thin compatibility layers for any future merge safety, but active app imports now point to the central theme tokens.
- Preserved feature-specific theme files such as media, approvals overview, projects dashboard, Petty Cash, purchase, productivity, and other module palettes because they are already scoped design systems rather than loose global colors.

Fourth-pass verification:

- No active Dart file imports `package:el_race/utils/color_utils.dart`.
- No active Dart file imports `package:el_race/core/constants/colors.dart` or `package:el_race/report_module/core/constants/colors.dart`.
- `dart analyze lib/core/theme/app_colors.dart lib/utils/color_utils.dart lib/core/constants lib/report_module/core/constants`: passed with no issues.
- `flutter test`: passed, 55 tests.
- `flutter build apk --debug`: passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `PROJECT_FILE_INDEX.md` regenerated successfully with 2321 indexed files.

---

## 2026-08-12 Source Main Sync Addendum

Source updates reviewed:

- Pulled latest `source/main` from `https://github.com/97jaw/Elrace-mobileapp-operations.git`.
- New upstream commits reviewed:
  - `6e66637 Add Firebase worker for Odoo circular/announcement publish jobs.`
  - `0568745 Deploy announcement push worker in us-central1.`

Changes integrated:

- Added `functions/odoo_announcement_push.js`.
- Updated `functions/index.js` to export `onOdooAnnouncementPushJob`.
- The new worker listens for `odoo_push_jobs/{jobId}` Firestore documents, fetches target staff FCM tokens from Odoo, sends batched announcement/circular push notifications, and writes job status back to Firestore.
- Kept the worker in `us-central1` as provided upstream because the source commit notes that `me-central-1` returns 403 for this project.

Merge discipline:

- Only the two new Firebase Functions changes were applied from upstream.
- Upstream did not include this project's local documentation, update-flow, splash, and color-token organization work, so those local architecture improvements were preserved.
- No generated documentation or Gradle/script deletions from upstream were applied.

Verification:

- `node --check functions/index.js`: passed.
- `node --check functions/odoo_announcement_push.js`: passed.
- `flutter test`: passed, 55 tests.
- `flutter build apk --debug`: passed and produced `build/app/outputs/flutter-apk/app-debug.apk`.
- `PROJECT_FILE_INDEX.md` regenerated successfully with 2320 indexed files.
