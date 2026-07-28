# Elrace Mobile App Operations - Source Project Full Audit Report

Generated at: 2026-07-28 16:27 +04:00  
Source project path: `C:\Users\Qossay\Desktop\project\Elrace-mobileapp-operations`  
Source repository: `97jaw/Elrace-mobileapp-operations`  
Source remote reviewed: `origin/main`  
Local source branch observed: `qossay_update`

## Purpose

This is a fixed baseline report for the original `Elrace-mobileapp-operations` project. It is stored in the organized project repository only as documentation. It is not generated automatically, not linked to any script, and not intended to replace `PROJECT_FULL_AUDIT_REPORT.md`.

Use this file as the "before/source project" reference. Use `PROJECT_FULL_AUDIT_REPORT.md` as the living report for the organized `elrace-mobileapp-operations-new` project and the progress made there.

## Executive Summary

The original `Elrace-mobileapp-operations` repository contains the same broad application domain and most of the active feature work, but it is less suitable as the main evaluation repository because it mixes active work, branch-specific changes, generated/build artifacts in the working directory, and legacy organizational patterns.

The source project is test-passing, but the local branch observed during this audit was not exactly equal to `origin/main`: it was **14 commits ahead** and **1 commit behind** `origin/main`. That means the source checkout is useful for comparison, but it should not be treated as a clean canonical release state without a branch decision.

Source project baseline rating: **7.3 / 10**

The organized project remains the better place to track progress because it has dedicated documentation, cleaner branch handling, synced `main/develop/staging`, and a clearer record of what was imported, cleaned, fixed, and verified.

## Verification Status

| Check | Result | Notes |
|---|---:|---|
| Git fetch `origin/main` | Pass | Fetched latest source `origin/main` for comparison. |
| Git working tree after audit | Clean | Temporary `pubspec.lock` change from `flutter test` was restored in the source checkout. |
| `flutter test` | Pass | `42/42` tests passed in the source project. |
| `dart analyze --format=machine` | Incomplete | Timed out after 600 seconds during this audit. No analyzer result should be assumed. |
| Debug APK build | Not run | Build verification was not repeated for the source project in this fixed baseline. |

## Source Git State

Observed local source branch:

- Branch: `qossay_update`
- Local HEAD: `67d02d48addf734a860f3aaa2420a73c1608b4b3`
- Remote `origin/main`: `1e3746579b35b5ac50d1590b01493d69b64a6283`
- Divergence from `origin/main`: **14 ahead / 1 behind**

Latest local source commits observed:

- `67d02d4` - chore: update pubspec lock
- `cd6fc11` - fix(startup): restore splash video gate and biometric retry
- `6387749` - Merge remote-tracking branch 'origin/main' into qossay_update
- `4571e99` - fix(hotfixes): HRMS, documents, splash startup, and enroll camera
- `6f6bda0` - fix(chat): stop message list rebuild loop from presence updates

## Project Inventory

Key counts from the source checkout:

- Indexed files from `rg --files`: **2210**
- Indexed total size: **135.27 MB**
- Flutter/Dart files: **1281**
- Test files: **9**
- Asset files: **527**
- Assets total size: **120.02 MB**

Top-level directories observed:

- `.cursor`
- `.dart_tool`
- `android`
- `assets`
- `build`
- `config`
- `doc`
- `docs`
- `functions`
- `functions-liveness`
- `ios`
- `lib`
- `packages`
- `scripts`
- `templates`
- `test`

## What The Source Project Contains

The source project includes the major app areas that were important during the sync and cleanup work:

- Chat and discussion flows.
- Home modules and dashboard widgets.
- HRMS and attendance-related views.
- Tasks, todo, QR survey, and global search flows.
- My Reports and site report photo/PDF flows.
- My Documents, Shared Documents, and signatures.
- Purchase, clients/vendors, projects, and timesheet modules.
- Firebase rules, Firebase functions, and liveness functions.
- Face recognition, liveness, anti-spoofing, and local ML-related assets.
- Large UI asset set including images, models, animations, and video assets.

## Organization Review

Strengths:

- The source project is functionally rich and contains active feature work.
- The test suite passes in the observed checkout.
- It includes useful hotfixes and recent app behavior fixes.
- Major backend/function folders are available in the same repository.

Weaknesses:

- The observed local branch is diverged from `origin/main`, so the source checkout is not a simple clean baseline.
- Generated or local tooling directories were present in the folder listing, including `.dart_tool` and `build`.
- The project has a large asset footprint, with assets taking about **120.02 MB**.
- State management and module layout are mixed across Provider, Riverpod, BLoC/Cubit, service classes, and legacy folders.
- Folder naming and module boundaries are less consistent than the organized project.
- Analyzer verification did not finish inside the audit timeout, so code-quality risk remains unquantified here.

## Comparison With The Organized Project

The organized `elrace-mobileapp-operations-new` repository is better for tracking evaluation progress because:

- It has explicit `PROJECT_FILE_INDEX.md` and `PROJECT_FULL_AUDIT_REPORT.md` documentation.
- It keeps a clearer history of imported changes, cleanup work, and fixes.
- It has `main`, `develop`, and `staging` synced intentionally.
- It has already documented what was imported from source and what was cleaned.
- It avoids relying on the source checkout's currently diverged branch state.
- It is the safer place to continue UI, startup, notification, and report-flow fixes.

## Risk Review

### Build And Runtime Health

Rating: **7.8 / 10**

The source project has passing tests, which is a strong signal. However, this audit did not run a debug APK build for the source checkout, and analyzer did not complete within 600 seconds.

### Code Quality

Rating: **7.0 / 10**

The codebase is large and active, but the timeout during analysis suggests that quality checks are heavier and less predictable than ideal. Mixed patterns and legacy module locations increase maintenance cost.

### Architecture

Rating: **7.2 / 10**

The app has feature separation in many areas, but the source project still mixes multiple state-management approaches and historical folder structures. It is workable, but not as clean as the organized project.

### Documentation And Traceability

Rating: **6.8 / 10**

The source project has docs folders, but it does not serve as the clear progress-tracking repository. The organized project is stronger because it has dedicated audit and file-index documentation.

### Assets And Performance

Rating: **7.0 / 10**

The source project has the same heavy asset footprint: **120.02 MB** in assets. This should be reviewed before release for unused or oversized images, videos, Lottie files, and model files.

### Branch Hygiene

Rating: **6.8 / 10**

The local source branch was **14 ahead / 1 behind** `origin/main`. That may be normal for active development, but it makes the source checkout less reliable as a stable comparison point unless the exact branch is specified every time.

## Scorecard

| Area | Score |
|---|---:|
| Feature completeness | 8.2 / 10 |
| Tests | 8.2 / 10 |
| Build confidence | 7.4 / 10 |
| Code quality | 7.0 / 10 |
| Architecture | 7.2 / 10 |
| Documentation | 6.8 / 10 |
| Branch hygiene | 6.8 / 10 |
| Assets/performance | 7.0 / 10 |
| Release readiness | 7.0 / 10 |

Overall: **7.3 / 10**

## Recommended Use

Use this file as the fixed source baseline:

1. Compare it against `PROJECT_FULL_AUDIT_REPORT.md` to show how the organized project improved.
2. Keep it unchanged unless you intentionally want to refresh the source baseline.
3. Continue updating `PROJECT_FULL_AUDIT_REPORT.md` for progress in `elrace-mobileapp-operations-new`.
4. If the source project gets major new work, import only the needed changes into the organized project and document them in the living audit report.

## Immediate Follow-Up Ideas

1. Run a full source `dart analyze` again when there is time and record the exact warning/error counts.
2. Run a source debug build only if the source project itself will be delivered.
3. Keep using the organized repository for evaluation, commits, release checks, and progress documentation.
4. Avoid treating the local source branch as `main` unless it is explicitly merged or reset to `origin/main`.
