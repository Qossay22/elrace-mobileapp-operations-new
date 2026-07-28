# Asset Usage Report

Date: 2026-07-23

## Summary

- Source `assets/` folder: **515 files**, about **115.41 MB**.
- Debug Flutter asset bundle after cleanup: **493 files**, about **77 MB**.
- Debug APK after cleanup: **365.96 MB**.
- Previous observed debug APK size before this pass: about **377.53 MB**.
- Immediate debug APK reduction: about **11.57 MB**.

## Changes Applied

### `assets/json/`

Before:

- `pubspec.yaml` included the whole `assets/json/` folder.
- This bundled `assets/json/logo.json`, which is about **18.26 MB** and was not referenced from `lib`.

After:

- `pubspec.yaml` now includes only the JSON files that are referenced by the app:
  - `assets/json/blink.json`
  - `assets/json/face_detecting.json`
  - `assets/json/hold.json`
  - `assets/json/inside.json`
  - `assets/json/left.json`
  - `assets/json/right.json`
  - `assets/json/smile.json`
- `assets/json/logo.json` remains in the repository, but is no longer bundled.

### `assets/antispoof/`

Before:

- `pubspec.yaml` included the whole `assets/antispoof/` folder.
- This bundled TensorFlow saved_model folders that are not referenced by Flutter runtime code.

After:

- `pubspec.yaml` now includes only the two TFLite files referenced by `AntispoofConfig`:
  - `assets/antispoof/minifasnet_v1se_4.0_80x80.tflite`
  - `assets/antispoof/minifasnet_v2_2.7_80x80.tflite`
- The saved_model folders remain in the repository for model provenance/retraining reference, but are no longer bundled.

## Verified Bundle Presence

Present in `flutter_assets`:

- `assets/json/blink.json`
- `assets/json/face_detecting.json`
- `assets/antispoof/minifasnet_v1se_4.0_80x80.tflite`
- `assets/antispoof/minifasnet_v2_2.7_80x80.tflite`
- `assets/mp4/splash.mp4`
- `assets/mobilefacenet_512.tflite`

Excluded from `flutter_assets`:

- `assets/json/logo.json`
- `assets/antispoof/_tf_MiniFASNetV1SE/saved_model.pb`

## Largest Remaining Assets To Review

| Asset | Approx Size | Current status | Recommendation |
|---|---:|---|---|
| `assets/mobilefacenet_512.tflite` | 13.01 MB | Used by face recognition | Keep unless server/downloaded model strategy is introduced |
| `assets/gif/ai.gif` | 7.74 MB | Used in coming-soon UI | Replace with optimized WebP/MP4 or smaller animation |
| `assets/newapp/task_managment_widget_backdround.png` | 4.49 MB | Used by home task widget | Compress or convert to WebP |
| `assets/png/pettycash_new_bg_old2.png` | 2.69 MB | Usage not confirmed in this pass | Search deeper before bundling decisions |
| `assets/newapp/test_petty_cach_image...` | 2.60 MB | Usage not confirmed in this pass | Verify and remove from bundle if unused |
| `assets/newapp/company_document_tab...` | 2.52 MB | Usage not confirmed in this pass | Compress or remove from bundle if unused |
| `assets/newapp/shared_documents_folder...` | 2.34 MB | Usage not confirmed in this pass | Compress or remove from bundle if unused |

## Next Safe Steps

- Replace `assets/gif/ai.gif` with a smaller asset.
- Compress large PNG backgrounds used in `assets/newapp/`.
- Continue replacing broad directory asset declarations with explicit file lists for high-risk folders.
- Run `flutter build appbundle --analyze-size` before release to separate Dart code, native libs, and assets accurately.
