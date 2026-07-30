# Project Full Audit Report

Generated at: 2026-07-30 10:45 +04:00
Project: `elrace-mobileapp-operations-new`
Source sync target reviewed: `97jaw/Elrace-mobileapp-operations/main` at `1d9e265`

## Executive Summary

The project was synced with the latest `source/main` updates from `Elrace-mobileapp-operations` while preserving the local project organization files that are intentionally maintained in this repository.

Current overall project rating: **8.5 / 10**

The application dependencies resolve, the Flutter test suite passes, and a debug APK builds successfully. This pass improves login/chat/QR security by removing sensitive logging, and improves asset/performance posture by deleting two large unused assets. The main remaining issue is analyzer reliability in this workspace: analyzer commands still time out after extended runs, so analyzer status is not treated as passed in this audit.

## Verification Status

| Check | Result | Notes |
|---|---:|---|
| `git fetch source main --prune` | Pass | Updated `source/main` from `4571e99` to `1d9e265`. |
| Merge conflict resolution | Pass | App code/assets resolved to `source/main`; local documentation and maintenance structure preserved. |
| Conflict marker scan | Pass | `rg "^(<<<<<<<|=======|>>>>>>>)"` found no merge conflict markers. |
| `git diff --check` | Pass | No whitespace or conflict-marker errors. |
| `flutter pub get` | Pass | Dependencies resolve successfully; 181 packages report newer incompatible versions. |
| `flutter test` | Pass | `42/42` tests passed after security and asset cleanup. |
| `flutter build apk --debug` | Pass | Built `build/app/outputs/flutter-apk/app-debug.apk` after asset cleanup. |
| `dart analyze --format=machine` | Timeout | Timed out after ~3 minutes, then again after ~7 minutes. |
| `flutter analyze` | Timeout | Timed out after ~7 minutes. |
| Targeted `dart analyze` | Timeout | Also timed out on the changed login/chat files. |

## Project Inventory

`PROJECT_FILE_INDEX.md` was regenerated on 2026-07-30 after the security/code-quality pass.

Key counts:

- Indexed files: **2280**
- Indexed total size: **104.51 MB**
- Flutter/Dart files from `rg --files`: **1292**
- Test files: **9**
- Asset files: **525**
- App assets total in file index: **88.76 MB**
- Flutter app code total in file index: **1274 files, 10.32 MB**

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
| Build health | 9.0 / 10 |
| Tests | 8.5 / 10 |
| Security | 8.2 / 10 |
| Code quality | 8.0 / 10 |
| Architecture | 8.0 / 10 |
| UI/UX organization | 8.2 / 10 |
| Assets/performance | 8.1 / 10 |
| Documentation | 8.7 / 10 |
| Release readiness | 8.0 / 10 |

Overall: **8.5 / 10**

## Immediate Next Steps

1. Investigate why `dart analyze` / `flutter analyze` hang in this workspace.
2. Continue removing sensitive or noisy logs from tasks, project data, QR survey, and media modules.
3. Run a release build check when signing configuration is available.
4. Re-run Firebase Functions dependency audit and plan semver-major upgrades separately.
5. Do one Android device smoke test for login, home, notifications, tasks/tickets, approvals, camera, My Actions, and My Notes.
6. Continue asset cleanup to reduce the 88.76 MB app asset footprint.

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
