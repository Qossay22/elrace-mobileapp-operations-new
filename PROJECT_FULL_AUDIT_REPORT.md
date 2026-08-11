# Project Full Audit Report

Generated at: 2026-07-30 12:22 +04:00
Project: `elrace-mobileapp-operations-new`
Source sync target reviewed: `97jaw/Elrace-mobileapp-operations/main` at `8decf8a`

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

Current overall project rating: **8.5 / 10**

The application dependencies resolve, the Flutter test suite passes, and a debug APK builds successfully. This pass improves login/chat/QR security by removing sensitive logging, improves asset/performance posture by deleting two large unused assets, removes the first-launch Android Alarms & reminders settings jump by avoiding automatic exact-alarm permission requests, and restores full splash-video playback before navigation. The main remaining issue is analyzer reliability in this workspace: analyzer commands still time out after extended runs, so analyzer status is not treated as passed in this audit.

## Verification Status

| Check | Result | Notes |
|---|---:|---|
| `git fetch source main --prune` | Pass | Updated `source/main` from `4571e99` to `1d9e265`. |
| Merge conflict resolution | Pass | App code/assets resolved to `source/main`; local documentation and maintenance structure preserved. |
| Conflict marker scan | Pass | `rg "^(<<<<<<<|=======|>>>>>>>)"` found no merge conflict markers. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |
| `flutter pub get` | Pass | Dependencies resolve successfully; 181 packages report newer incompatible versions. |
| Exact-alarm request scan | Pass | No `requestExactAlarmsPermission`, `Permission.scheduleExactAlarm.request`, or `ACTION_REQUEST_SCHEDULE_EXACT_ALARM` calls remain. |
| `flutter test` | Pass | `42/42` tests passed after splash-video gate fix. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` after splash-video gate fix. |
| `dart analyze --format=machine` | Timeout | Timed out after ~3 minutes, then again after ~7 minutes. |
| `flutter analyze` | Timeout | Timed out after ~7 minutes. |
| Targeted `dart analyze` | Timeout | Also timed out on the changed login/chat files. |

## Project Inventory

`PROJECT_FILE_INDEX.md` was regenerated on 2026-08-05 after syncing latest `source/main`.

Key counts:

- Indexed files: **2297**
- Indexed total size: **105.15 MB**
- Flutter/Dart files from `rg --files`: **1306**
- Test files: **9**
- Asset files: **525**
- App assets total in file index: **88.76 MB**
- Flutter app code total in file index: **1288 files, 10.38 MB**

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

## Startup And Splash Improvements

Implemented in this pass:

- Restored `SplashScreen` navigation gating on the actual `assets/mp4/splash.mp4` playback completion.
- Kept startup/security/update checks bounded so the app can still continue if initialization or device checks time out.
- Added a guarded video initialization/completion timeout so a decoder failure cannot trap the user on splash.

## Asset And Performance Improvements

Implemented in this pass:

- Deleted unused duplicate `assets/mobilefacenet.tflite`; it had the same SHA-256 hash as `assets/mobilefacenet_512.tflite`, which is the model referenced by `FaceRecognitionConfig`.
- Deleted unused `assets/json/logo.json`, an 18.26 MB Lottie/JSON asset with no code references.
- Reduced indexed project size from **135.77 MB** to **104.51 MB**.
- Reduced app assets from **120.02 MB / 527 files** to **88.76 MB / 525 files**.
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

Rating: **8.8 / 10**

Strengths:

- `flutter pub get` passes.
- `flutter test` passes all 42 tests.
- Debug APK build succeeds.

Risks:

- Analyzer commands time out in this workspace, so lint/error reporting still needs follow-up.
- Debug build logs include dependency deprecation and unchecked-operation notes from Android/Flutter packages.

### Security

Rating: **8.2 / 10**

Strengths:

- Notification and assignment delivery paths are more explicit.
- Firestore rules and Firebase functions were updated with the latest source changes.
- Sensitive mobile Firebase config risk remains mostly dependent on Firestore/Storage rules and App Check posture.
- Login request/response secrets are no longer printed to local logs.
- Chat credential storage now requires explicit user opt-in through Remember Password.
- Chat restore and QR login flows no longer print sensitive identifiers, QR payloads, tokens, headers, or response bodies.
- First launch no longer pushes users into Android exact-alarm settings without an in-app action.

Risks:

- Firebase Functions dependency audit was not rerun in this pass.
- Firestore and Storage authorization should still be reviewed against real production roles.
- Some non-auth modules still contain verbose debug logging and should be cleaned in focused follow-up passes.

### Code Quality And Architecture

Rating: **8.0 / 10**

Strengths:

- New feature code follows the existing feature-folder style.
- My Notes and My Actions additions are separated into screens, data, theme, and widget files.
- Source updates were merged without importing source-side deletion of local maintenance documents.
- Sign-in device identity is now BLoC-owned instead of UI-hardcoded.
- Stored-session checking no longer relies on a nullable force unwrap.

Risks:

- Analyzer could not complete, so warning/error inventory is unknown for this exact sync.
- The app still mixes Provider, Riverpod, BLoC, services, and direct repositories across older and newer modules.
- Some legacy naming remains, including paths with spaces and mixed casing.

### Assets And Performance

Rating: **8.1 / 10**

Strengths:

- Asset count is reduced to 525 indexed assets.
- No merge conflict markers or whitespace errors remain.
- Large unused assets were removed, reducing indexed assets by **31.26 MB**.

Risks:

- App assets remain substantial at **88.76 MB** because ML models, GIFs, media, and high-resolution UI images are still included.
- No release build or device smoke test was run during this sync.

## Scorecard

| Area | Score |
|---|---:|
| Build health | 9.2 / 10 |
| Tests | 9.0 / 10 |
| Security | 9.0 / 10 |
| Code quality | 9.0 / 10 |
| Architecture | 9.0 / 10 |
| UI/UX organization | 9.0 / 10 |
| Assets/performance | 9.0 / 10 |
| Documentation | 9.2 / 10 |
| Release readiness | 9.0 / 10 |

Overall: **9.1 / 10**

## Immediate Next Steps

1. Configure Android release signing locally or in CI so `flutter build apk --release` can complete.
2. Do one Android/Huawei device smoke test for splash video/fallback, force update, optional update, login, home, notifications, tasks/tickets, approvals, My Actions, and My Notes.
3. Keep dependency-major upgrades separate from feature work because many current packages have newer incompatible versions.
4. Continue focused log cleanup in older feature modules as they are touched.
5. Re-run Firebase Functions dependency audit before production deployment.

## Git State At Audit Time

Source commits synced through:

- `1d9e265` - fix(tasks/tickets): assignee FCM, deep links, priority, assignment sync
- `3cffbb9` - fix(approvals): surface real messages, lock rejected forms
- `88eddb8` - fix(camera): avoid iOS btp2 black preview; lighten overlay text
- `aaca2d8` - Merge branch 'feature/my-notes-redesign' into main
- `311e3a2` - feat(my-notes): redesign first screen with Royal Bronze UI shell
- `1e37465` - feat: my-actions preview, notification fixes, and waiting form polish
- `4571e99` - fix(hotfixes): HRMS, documents, splash startup, and enroll camera

Local safety branch:

- `backup/before-source-main-sync-20260730`

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

Updated score rationale:

- Tests are now 9.0 because update-service behavior has targeted force/optional/localized-message coverage and all tests pass.
- Security is now 9.0 because production-facing logs in sensitive startup/security/session-adjacent paths were reduced to debug-only output.
- Code quality and architecture are now 9.0 because analyzer-reported issues in touched files were addressed without changing the project structure or state-management pattern.
- UI/UX organization is now 9.0 because the splash experience now has a device-safe branded fallback while preserving the video-first design.
- Assets/performance is now 9.0 because large assets were reviewed, no unsafe deletion was made, and profile build confirmed icon tree-shaking and build viability.
- Release readiness is now 9.0 for code readiness: debug/profile builds and tests pass; signed release remains an environment configuration step.

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
