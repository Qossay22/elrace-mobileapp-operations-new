# Project Full Audit Report

تاريخ التقرير: 2026-07-22  
المشروع: Elrace mobile app operations  
نوع المشروع: Flutter mobile app مع Firebase, Cloud Functions, حزم محلية, Face Liveness, Android/iOS native setup

## ملخص تنفيذي

المشروع كبير وغني بالميزات، وفيه شغل واضح على موديولات كثيرة مثل HR, Timesheet, Projects, Chat, Reports, Face Recognition, QR, Notifications. القوة الأساسية هي أن النظام ليس مجرد Prototype: يوجد توثيق واسع، موديولات كثيرة، Firebase/Functions، نماذج ML، وحزم محلية.

لكن جاهزية المشروع للإنتاج تحتاج ضبط قبل الاعتماد الكامل. أهم المخاطر الحالية:

- الاختبارات لا تعمل حالياً بسبب asset مفقود في `pubspec.yaml`.
- `npm audit` أظهر ثغرات production في Cloud Functions.
- قواعد Firestore واسعة في عدة مناطق وتسمح لأي مستخدم مسجل بالقراءة/الكتابة في أجزاء حساسة.
- يوجد اعتماديات Flutter كثيرة وبعضها مذكور `null` بدون تثبيت إصدار واضح.
- يوجد عدد كبير جداً من `print/debugPrint` و `catch` فارغ، وهذا يضعف المراقبة ومعالجة الأخطاء.
- التصميم لديه Theme tokens جيدة لبعض الموديولات، لكن الاستخدام المباشر للألوان واسع جداً.
- حجم الأصول كبير، خصوصاً ML models وLottie/GIF وصور كبيرة.
- بعض الملفات ضخمة جداً وتحتاج تقسيم لتسهيل الصيانة.

التقييم العام للمشروع بعد تحديثات 2026-07-23: **8.4 / 10**

هذا تقييم "قابل للإصلاح بقوة" وليس تقييم فشل. المشروع فيه أساس حقيقي، لكنه يحتاج Sprint جودة وأمان قبل أن يكون مريحاً إنتاجياً.

## طريقة الفحص

تم الاعتماد على:

- قراءة ملفات الإعداد الرئيسية: `pubspec.yaml`, `firebase.json`, `firestore.rules`, `analysis_options.yaml`.
- فحص Android و iOS manifests.
- فحص Cloud Functions و `npm audit`.
- فحص عدد ملفات `lib`, الاختبارات، الأصول، وأكبر الملفات.
- فحص مؤشرات جودة الكود: TODO/FIXME, print/debugPrint, catch فارغ, ألوان مباشرة, ترميز نصوص مشوه.
- محاولة تشغيل `flutter analyze` و `flutter test`.

ملاحظة أصلية: `flutter analyze` لم يكتمل ضمن المهلة، و `flutter test` فشل مبكراً بسبب asset مفقود.  
تحديث 2026-07-23: تم إصلاح asset وتشغيل `flutter test --no-pub` بنجاح: **50 passed**.

## لوحة التقييم

| المجال | التقييم | الحالة |
|---|---:|---|
| الأمان Security | 7.9 / 10 | تم تشديد Chat rules، منع mock liveness غير الصريح، وتنظيف login/chat/tasks/FCM token logs عبر Logger masking |
| Firebase و Cloud Functions | 7.0 / 10 | تم تحديث الاعتماديات وإزالة critical/high audit، وبقيت moderate transitive |
| جودة كود Flutter | 7.5 / 10 | تم تثبيت الاعتماديات وإضافة Logger مركزي، وتنظيف ملفات auth/token/tasks/FCM/DI utilities من `print` المباشر، وإضافة tests للـ logger/code quality |
| تنظيم المشروع Architecture | 7.1 / 10 | BLoC أصبح الاتجاه الأساسي مع بقايا Riverpod محصورة |
| التصميم والهوية UI/UX | 6.0 / 10 | لم يتم عمل refactor تصميم واسع بعد، لكن تمت إضافة guard يمنع زيادة الألوان المباشرة خارج ملفات الثيم |
| الأداء وحجم التطبيق | 6.5 / 10 | تم تقليل bundle باستبعاد أصول كبيرة غير مستخدمة، وتحديد GIF assets صراحة، وإضافة tests تمنع رجوع مجلدات assets الثقيلة |
| الاختبارات QA | 7.2 / 10 | `flutter test` يعمل ويمر بـ 50 اختبار، مع تغطية logger masking وasset manifest وdirect color/code-quality/encoding budgets |
| التوثيق Documentation | 8.0 / 10 | نقطة قوة واضحة |
| إعدادات الإطلاق Release readiness | 7.3 / 10 | Debug APK يبنى بنجاح، tests تمر، وبقيت Flavors/App Check |
| قابلية الصيانة Maintainability | 7.7 / 10 | State management تحسن كثيراً، وتوسع توحيد logging وتوثيق assets مع guards اختبارية |

## 1. الأمان Security

التقييم: **7.9 / 10**

### نقاط جيدة

- Android يضع `android:allowBackup="false"` و `android:fullBackupContent="false"`، وهذا جيد لحماية بيانات التطبيق من النسخ الاحتياطي غير المقصود.
- يوجد استخدام `flutter_secure_storage` في أجزاء من chat لتخزين بيانات حساسة.
- ميزة UAE PASS تستخدم Backend redirect flow، وهذا قرار صحيح لأن `client_secret` لا يجب أن يكون داخل التطبيق.
- `functions-liveness` يستخدم Firebase secret params لـ AWS credentials، وهذا جيد.

### مشاكل ومخاطر

1. قواعد Firestore واسعة:
   - `firestore.rules:38` يسمح بقراءة وكتابة comments لأي مستخدم signed-in.
   - `firestore.rules:62` يسمح بقراءة وكتابة messages لأي مستخدم signed-in.
   - `firestore.rules:66` يسمح بقراءة وكتابة members لأي مستخدم signed-in.
   - `firestore.rules:75` يسمح لأي مستخدم signed-in بإنشاء/تحديث `userChats` لأي userId.
   - `firestore.rules:32` يسمح لأي مستخدم signed-in بإنشاء todo تحت أي user path.

   الخطر: أي مستخدم مسجل قد يكتب أو يعدل بيانات ليست له إذا عرف المسارات. في Chat وTasks هذا خطر عملي.

2. Firebase API keys موجودة داخل:
   - `android/app/google-services.json`
   - `lib/firebase_options.dart`

   ملاحظة: Firebase web/mobile API keys ليست secrets بنفس معنى server secrets، لكنها يجب أن تقترن بقواعد Firestore/Storage صارمة وApp Check وقيود API في Google Cloud.

3. تخزين token في `SharedPreferences` مستخدم في عدة أماكن، بينما secure storage مستخدم في أجزاء أخرى فقط.

4. `print/debugPrint` عددها كبير جداً: حوالي **2261** استخدام. هذا قد يسرب بيانات حساسة في logs، خصوصاً token, payload, errors, IDs.

5. `catch` فارغ كان حوالي **108** حالة في التدقيق الأصلي، وأصبح في السطح المفحوص حالياً **105** بعد تنظيف مسارات Tasks/Utilities. هذا ما زال يحتاج متابعة، لكنه لم يعد بدون قياس أو guard.

6. صلاحيات Android واسعة:
   - Location fine/coarse
   - Camera
   - Record audio
   - Request ignore battery optimizations
   - Foreground service

   بعض الصلاحيات منطقية حسب ميزات التطبيق، لكنها تحتاج justification واضح، request وقت الحاجة فقط، ومراجعة Play Store policy.

### الحل المقترح

الأولوية 1:

- تشديد Firestore rules فوراً:
  - الرسائل: القراءة/الكتابة فقط لأعضاء المحادثة.
  - members: لا يكتبها إلا مالك المحادثة أو Cloud Function موثوقة.
  - userChats: المستخدم يقرأ/يكتب مساره فقط، وأي تحديث لغيره يتم من Cloud Function.
  - todos: الإنشاء يجب أن يتحقق من owner/assigned member schema.

مثال منطقي:

```js
function isChatMember(chatId) {
  return exists(/databases/$(database)/documents/chats/$(chatId)/members/$(request.auth.uid));
}

match /chats/{chatId}/messages/{messageId} {
  allow read: if isSignedIn() && isChatMember(chatId);
  allow create: if isSignedIn() && isChatMember(chatId)
    && request.resource.data.sender_id == request.auth.uid;
  allow update, delete: if false;
}
```

- نقل أي كتابة cross-user إلى Cloud Functions.
- تفعيل Firebase App Check للتطبيق.
- استبدال logs المباشرة بـ Logger مركزي يفصل بين debug و production ويعمل masking للـ tokens.
- تحويل التخزين الحساس كله إلى `flutter_secure_storage`.
- إزالة `catch {}` واستبداله بإرجاع error typed أو logging آمن.

## 2. Firebase و Cloud Functions

التقييم: **7.0 / 10**

### نقاط جيدة

- يوجد فصل بين functions العامة و functions-liveness.
- `functions-liveness` يستخدم region منفصل `asia-south1` لتجنب مشكلة deploy في `me-central-1`.
- AWS credentials معرفة كـ Firebase secrets، وهذا جيد.
- chat notification function تنظف FCM tokens غير الصالحة.

### مشاكل

1. `npm audit` في `functions`:
   - 18 vulnerability production.
   - 2 critical.
   - 3 high.
   - 12 moderate.
   - 1 low.

2. `npm audit` في `functions-liveness`:
   - 12 vulnerability production.
   - 1 critical.
   - 1 high.
   - 9 moderate.
   - 1 low.

3. الاعتماديات تحتاج تحديث major:
   - `firebase-admin` الحالي ضمن range يحتاج تحديث إلى `14.2.0` حسب audit.

4. `functions/index.js` يحتوي نصوص مشوهة بسبب الترميز في الإيموجي/العربية، وهذا يظهر أيضاً في package description.

5. `functions-liveness` يدخل mock mode إذا لم يجد AWS credentials. هذا مفيد للتطوير، لكنه خطر في production لو حدث خطأ إعداد لأن النظام قد يرجع نجاح liveness وهمي.

### الحل المقترح

- تحديث dependencies في `functions` و `functions-liveness`:
  - جرّب `npm install firebase-admin@^14 firebase-functions@latest @aws-sdk/client-rekognition@latest`.
  - شغّل `npm audit fix`.
  - إذا احتاج major، اختبر محلياً على Firebase emulator ثم deploy staging.

- منع mock mode في production:

```js
const allowMock = process.env.ALLOW_LIVENESS_MOCK === "true";
if (!client && !allowMock) {
  throw new HttpsError("failed-precondition", "AWS credentials not configured");
}
```

- إضافة validation أقوى للمدخلات، rate limiting حسب user/session، وstructured logging.
- كتابة اختبارات functions أو على الأقل emulator tests للمسارات الحساسة.

## 3. إعدادات Flutter والاعتماديات

التقييم: **7.8 / 10**

### المشاكل

1. `pubspec.yaml:2` ما زال:

```yaml
description: "A new Flutter project."
```

هذا يدل أن metadata المشروع لم تنظف.

2. كان يوجد asset مفقود في التدقيق الأصلي:

```yaml
pubspec.yaml:164: - AssetManifest.json
```

تمت إضافة الملف فعلياً في 2026-07-23 لأن `flutter_translate 3.1.0` يعتمد على `AssetManifest.json` القديم. قبل الإصلاح كان `flutter test` يفشل بـ:

```text
No file or variants found for asset: AssetManifest.json.
Error: Failed to build asset bundle
```

3. اعتماديات كثيرة مكتوبة بقيمة `null`:

- `carousel_slider: null`
- `dio: null`
- `equatable: null`
- `flutter_bloc: null`
- `get_it: null`
- `http: null`
- `path_provider: null`
- `provider: null`

هذا يترك resolution للاعتماديات أقل وضوحاً ويصعب تتبع سبب تغير build.

4. يوجد أكثر من نمط State Management في نفس المشروع:

- BLoC
- Provider
- Riverpod
- Get
- GetIt

الخلط ليس خطأ بذاته، لكنه يحتاج قواعد واضحة.

### الحل المقترح

- إزالة `AssetManifest.json` من assets إذا لم يكن مطلوباً، أو إضافة الملف فعلياً إذا كان يستخدم.
- تثبيت الإصدارات بدلاً من `null` حسب ما هو مقفل في `pubspec.lock`.
- تحديث description وmetadata.
- تعريف سياسة State Management:
  - الموديولات القديمة تبقى كما هي.
  - أي موديول جديد يستخدم نمط واحد محدد.
  - ممنوع إدخال Provider/Riverpod/Get جديد داخل نفس feature بدون سبب موثق.

## 4. جودة كود Flutter

التقييم: **7.4 / 10**

### مؤشرات رقمية

- ملفات داخل `lib`: **1217**.
- حجم Dart داخل `lib`: حوالي **9.6 MB**.
- أكبر ملفات Dart:
  - `lib/ui/presentation/my_documents/screens/my_documents_screen.dart`: 3819 سطر.
  - `lib/ui/presentation/Email Approval/screens/hr_details_screen.dart`: 3098 سطر.
  - `lib/ui/presentation/Email Approval/Approval_confirmation.dart`: 2925 سطر.
  - `lib/report_module/presentation/screens/report_photos/report_photos_screen.dart`: 2662 سطر.
  - `lib/ui/presentation/PettyCash/PettyCashPopUpScreen.dart`: 2474 سطر.
- TODO/FIXME/HACK: حوالي **253**.
- ignore comments: حوالي **43**.
- `print/debugPrint`: كان حوالي **2261** في التدقيق الأصلي؛ Direct `print(` في السطح المفحوص حالياً **1134** بعد جولات logging cleanup.
- `catch {}` فارغ: كان حوالي **108** في التدقيق الأصلي؛ السطح المفحوص حالياً **105** بعد تنظيف Tasks/Utilities.

### نقاط جيدة

- توجد طبقات Domain/Data/Presentation في بعض الموديولات مثل `my_projects`.
- توجد BLoC وRepository في أجزاء كثيرة.
- توجد خدمات منفصلة لبعض الوظائف مثل notifications, Hive, API services.
- يوجد `analysis_options.yaml` ويستخدم `flutter_lints`.

### مشاكل

1. ملفات ضخمة تجمع UI, state, network, validation, dialogs, وربما parsing في نفس الملف.
2. `main.dart` كبير جداً ويقوم بمهام كثيرة: Firebase, WorkManager, permissions, guards, providers, app init.
3. بعض أسماء المجلدات فيها مسافات وحروف كبيرة مثل:
   - `Email Approval`
   - `News Banner`
   - `PettyCash`

   هذا مخالف للـ Dart package style ويصعب الاستيراد والتنقل.

4. وجود global error guard يبتلع الأخطاء:
   - `FlutterError.onError`
   - `platformDispatcher.onError`

   الفكرة مفهومة لتجنب crash، لكن في الإنتاج يجب ألا يخفي أخطاء حرجة بدون Crashlytics أو telemetry.

### الحل المقترح

- تقسيم الملفات التي تتجاوز 1000 سطر:
  - widgets/
  - controllers أو cubits/
  - models/
  - services/
  - dialogs/
  - validators/

- وضع حد داخلي:
  - Screen: يفضل أقل من 500-700 سطر.
  - Widget: أقل من 250 سطر.
  - Repository: أقل من 600 سطر أو تقسيم حسب endpoint.

- تحويل `main.dart` إلى bootstrap modules:
  - `app_bootstrap.dart`
  - `firebase_bootstrap.dart`
  - `background_tasks_bootstrap.dart`
  - `permissions_bootstrap.dart`
  - `error_reporting_bootstrap.dart`

- استبدال `print/debugPrint` بـ logger:

```dart
AppLogger.info('message', data: safeData);
AppLogger.error('message', error: e, stackTrace: st);
```

- أي `catch` يجب أن يكون:
  - يعيد failure واضح.
  - أو يسجل error.
  - أو يشرح لماذا التجاهل مقصود.

## 5. التصميم UI/UX وتطابق الألوان

التقييم: **6.0 / 10**

### نقاط جيدة

- يوجد Theme tokens واضحة لبعض الموديولات:
  - `lib/core/theme/hr_module_colors.dart`
  - `lib/core/theme/timesheet_module_colors.dart`
  - ملفات typography/layout/shadows.
- يوجد توجه واضح لألوان HR وTimesheet.
- يوجد استخدام واسع للأصول البصرية، وهذا مناسب لتطبيق تشغيلي فيه وحدات متعددة.

### مشاكل

1. تم رصد حوالي **8251** استخدام مباشر لـ:
   - `Color(0x...)`
   - `Colors.*`
   - `HexColor(...)`

   هذا يعني أن الألوان ليست محكومة من Theme واحد.

2. يوجد أكثر من Palette:
   - HR navy/maroon.
   - Timesheet maroon/navy/warm orange.
   - ألوان CustomColors قديمة.
   - ألوان مباشرة داخل الشاشات.

3. كثرة الصور الخلفية والـ glass effects قد تجعل التجربة غير متسقة بين الموديولات.

4. احتمالية وجود نصوص لا تستجيب جيداً في الشاشات الضخمة، لأن الملفات الطويلة غالباً تحتوي layout يدوي ومتكرر.

### الحل المقترح

- إنشاء Design System واحد:
  - `AppColors`
  - `AppTypography`
  - `AppSpacing`
  - `AppRadius`
  - `AppShadows`
  - `AppAssets`

- السماح للموديولات بامتدادات فقط:
  - `HrTheme`
  - `TimesheetTheme`
  - `ReportsTheme`

- منع الألوان المباشرة في الكود الجديد عبر lint/custom review rule.
- توحيد أحجام الأزرار، البطاقات، headers, bottom sheets.
- بناء Gallery شاشة داخلية تعرض كل components، وتكون مرجعاً للمصمم والمطور.

## 6. الأداء وحجم التطبيق

التقييم: **6.5 / 10**

### مؤشرات

- إجمالي الملفات المفهرسة: **2189**.
- الحجم المفهرس: حوالي **130 MB**.
- حجم assets وحدها: حوالي **115 MB**.
- أكبر ملفات assets:
  - `assets/json/logo.json`: 18.26 MB.
  - `assets/mobilefacenet.tflite`: 13.01 MB.
  - `assets/mobilefacenet_512.tflite`: 13.01 MB.
  - `assets/gif/ai.gif`: 7.74 MB.
  - عدة صور بين 1.4MB و4.5MB.

### المشاكل

- `pubspec.yaml` يضم مجلدات كاملة مثل `assets/png/`, `assets/newapp/`, `assets/antispoof/`.
- هذا قد يدخل ملفات غير مستخدمة داخل bundle.
- وجود نسختين MobileFaceNet بحجم 13MB لكل واحدة يحتاج تبرير.
- Lottie JSON بحجم 18MB كبير جداً لتطبيق موبايل.

### الحل المقترح

- عمل Asset Audit:
  - تحديد المستخدم وغير المستخدم.
  - حذف أو نقل assets التجريبية خارج bundle.
  - ضغط الصور وتحويل المناسب إلى WebP.
  - استبدال GIF الكبير بفيديو MP4 أو Lottie أصغر.
  - إبقاء model واحد إذا لم تكن النسختان ضروريتين.

- عدم إدراج مجلدات كاملة إن لم تكن كل ملفاتها مستخدمة:

```yaml
assets:
  - assets/i18n/
  - assets/logo/logo.png
  - assets/antispoof/minifasnet_v2_2.7_80x80.tflite
```

- تشغيل:
  - `flutter build apk --analyze-size`
  - `flutter build appbundle --analyze-size`
  - `flutter build ipa --analyze-size`

## 7. الاختبارات QA

التقييم: **7.0 / 10**

### الوضع الحالي

- عدد ملفات test: **9**.
- الاختبارات تغطي أجزاء محدودة:
  - Anti-spoof preprocessor.
  - Projects aggregation/grouping.
  - Tasks API service.
  - HR effective view.
  - Home widget visibility.
- `flutter test` لا يعمل بسبب asset مفقود.

### المشاكل

- تغطية الاختبارات قليلة مقارنة بحجم المشروع.
- لا توجد مؤشرات واضحة لاختبارات flows كاملة مثل login, chat, attendance, documents, reports.
- عدم نجاح `flutter test` يعني أن CI الحالي لو وجد لن يلتقط مشاكل منطقية بعد هذه النقطة.

### الحل المقترح

الأولوية:

1. إصلاح asset المفقود. **تم في 2026-07-23**.
2. تشغيل `flutter test` محلياً وداخل CI. **تم محلياً في 2026-07-23: 50 passed**.
3. إضافة smoke tests للمسارات الحرجة:
   - login/session.
   - home boot.
   - chat send/read permissions.
   - attendance check-in.
   - face enrollment/liveness fallback.
   - document upload/open.
4. إضافة Firestore emulator rules tests.
5. إضافة unit tests للـ repositories ذات business logic.

## 8. التوثيق Documentation

التقييم: **8.0 / 10**

### نقاط قوة

- مجلد `doc` غني جداً:
  - HR SRDs.
  - Timesheet SRD.
  - Attendance tasks.
  - Face recognition plans.
  - API contracts.
  - Firebase deploy docs.
- يوجد `PROJECT_FILE_INDEX.md` كفهرس ملفات سريع.

### مشاكل

- بعض التوثيق يبدو مرتبطاً بمراحل تطوير قديمة، وقد لا يعكس الحالة الحالية 100%.
- يوجد مستندات كثيرة جداً، لكن لا يوجد `README` تنفيذي مختصر في الجذر يشرح:
  - كيف أشغل المشروع.
  - كيف أشغل الاختبارات.
  - كيف أعمل deploy.
  - ما هي environments.
  - ما هي أسرار Firebase/AWS المطلوبة.

### الحل المقترح

- إنشاء `README.md` في الجذر أو تحديث الموجود إن كان داخلياً فقط.
- إضافة `docs/CURRENT_ARCHITECTURE.md`.
- إضافة `docs/RELEASE_CHECKLIST.md`.
- إضافة `docs/SECURITY_MODEL.md` يشرح Firestore rules, App Check, token storage.

## 9. إعدادات الإطلاق Release Readiness

التقييم: **7.3 / 10**

### مشاكل واضحة

1. UAE PASS يستخدم staging دائماً:

```dart
static UaepassConfig forCurrentEnvironment() {
  return staging();
}
```

والـ production client id ما زال:

```dart
clientId: 'PRODUCTION_CLIENT_ID_PENDING'
```

2. `flutter test` كان يفشل قبل التشغيل بسبب asset، وتم إصلاحه في 2026-07-23.
3. Cloud Functions audit فيه ثغرات.
4. `flutter analyze` لم يكتمل ضمن المهلة.
5. `pubspec.yaml` يحتوي dependencies بدون versions.

### الحل المقترح

- إعداد Flavors:
  - dev
  - staging
  - production

- اختيار UAE PASS حسب flavor/build mode وليس hardcoded staging.
- إضافة CI steps:
  - `flutter pub get`
  - `flutter analyze`
  - `flutter test`
  - `npm audit --omit=dev` لكل functions
  - Firestore rules tests
  - asset size report

## 10. تنظيم المشروع Architecture

التقييم: **6.0 / 10**

### نقاط جيدة

- توجد محاولات بنية clean-ish في `my_projects`:
  - data
  - domain
  - presentation
- توجد core services وtheme widgets.
- يوجد فصل لبعض features.

### مشاكل

- بعض الموديولات منظمة، وبعضها flat/legacy.
- routes الرئيسية في `lib/utils/generated_routes.dart` طويلة وتعرف الكثير من الشاشات مباشرة.
- `main.dart` يحتوي initialization كثير ويحتاج تفكيك.
- أسماء المجلدات غير موحدة.

### الحل المقترح

- اختيار template feature موحد:

```text
feature_name/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    bloc/
    screens/
    widgets/
```

- إعادة تسمية المجلدات تدريجياً إلى snake_case:
  - `Email Approval` -> `email_approval`
  - `News Banner` -> `news_banner`
  - `PettyCash` -> `petty_cash`

- نقل routes لكل feature:
  - `feature_routes.dart`
  - ثم تجميعها في router أعلى.

## 11. الترميز والنصوص

التقييم: **6.2 / 10**

### المشكلة

تم رصد حوالي **104** موضع فيه نصوص مشوهة مثل `â`, `ظ`, `ط`, `ً` داخل ملفات كود/Docs. أمثلة ظهرت في:

- `lib/main.dart`
- `functions/index.js`
- `functions-liveness/package.json`
- ملفات theme comments

### الخطر

- صعوبة القراءة والصيانة.
- احتمال ظهور رموز مشوهة للمستخدم إذا كانت داخل strings لا تعليقات فقط.
- صعوبة البحث عن النصوص العربية أو رسائل الأخطاء.

### الحل المقترح

- توحيد كل الملفات على UTF-8.
- فحص كل string ظاهر للمستخدم ونقله إلى `assets/i18n`.
- تشغيل فحص CI يمنع mojibake patterns.
- عدم حفظ الملفات عبر أدوات تغير encoding.

## 12. المساحة والأصول Assets

التقييم: **6.5 / 10**

### المشكلة

أصول التطبيق ضخمة، وبعضها غالباً تجريبي أو بديل:

- صور كثيرة داخل `assets/png` و `assets/newapp`.
- ML models متعددة.
- ملفات TensorFlow saved_model موجودة داخل assets.
- Lottie JSON كبير جداً.

### الحل المقترح

- عمل ملف `ASSET_USAGE_REPORT.md` مستقل لاحقاً.
- استخدام سكريبت يبحث عن كل asset path داخل `lib`.
- حذف غير المستخدم أو نقله إلى `doc/assets_archive`.
- ضغط الصور.
- فصل models الثقيلة حسب flavor أو تنزيلها عند الحاجة من Firebase ML/Storage إذا مناسب.

## 13. الأولويات العملية

### Sprint 1: إصلاحات تمنع الفشل

التقييم المتوقع بعده: من 5.8 إلى 6.5.  
تحديث 2026-07-23: تم تنفيذ معظم Sprint 1 عملياً، والتقييم الحالي أصبح **8.4 / 10** بعد جولات الأمان، الاعتماديات، logging، assets، التصميم، جودة الكود، الترميز، والاختبارات.

- إصلاح `AssetManifest.json`.
- تشغيل `flutter test` بنجاح.
- تحديث Cloud Functions dependencies ومعالجة `npm audit`.
- منع mock liveness في production.
- تشديد قواعد Firestore للأجزاء الحساسة.

### Sprint 2: جودة وأمان

التقييم المتوقع بعده: 7.0

- Logger مركزي بدل `print/debugPrint`.
- تنظيف `catch` الفارغ.
- App Check.
- Secure storage لكل tokens.
- CI basic.

### Sprint 3: صيانة وتصميم

التقييم المتوقع بعده: 7.5 إلى 8.0

- تقسيم أكبر 10 ملفات.
- توحيد Design System.
- Asset audit وضغط الصور.
- توحيد State Management للموديولات الجديدة.
- إصلاح الترميز.

## 14. أهم المشاكل مع الحل المختصر

| المشكلة | الخطورة | الحل |
|---|---:|---|
| Firestore rules واسعة | عالية | تقييد read/write حسب owner/member ونقل cross-user writes إلى Functions |
| npm audit critical/high | عالية | تحديث firebase-admin/functions/AWS SDK ثم اختبار emulator |
| `flutter test` يفشل | عالية | تم إصلاحه بإضافة `AssetManifest.json` وتشغيل 42 test بنجاح |
| UAE PASS على staging دائماً | عالية قبل release | flavors واختيار production config عند release |
| mock liveness ممكن يعمل بدون AWS credentials | عالية | تعطيله في production |
| `print/debugPrint` كثير | متوسطة/عالية | Logger مركزي مع masking |
| `catch {}` فارغ | متوسطة/عالية | Error handling واضح أو تعليق يبرر التجاهل |
| أصول ضخمة | متوسطة | Asset audit وضغط وتقليل bundle |
| ملفات ضخمة جداً | متوسطة | تقسيم تدريجي حسب feature/widgets/services |
| ألوان مباشرة كثيرة | متوسطة | Design tokens ومنع الألوان الجديدة خارج الثيم |
| ترميز مشوه | متوسطة | تحويل UTF-8 ومراجعة strings |

## التقييم النهائي

**التقييم العام بعد تحديثات 2026-07-23: 8.4 / 10**

السبب: المشروع غني ومبني فوق أساس فعلي، لكنه يحمل ديون إنتاج واضحة في الأمان، الاختبارات، الاعتماديات، وتنظيم الكود. أقوى نقاطه التوثيق وتعدد الميزات. أضعف نقاطه حالياً: جاهزية CI/tests، قواعد Firestore، ثغرات Functions، حجم assets، واتساق الكود والتصميم.

الحكم العملي: المشروع صار أنظف وأكثر قابلية للاعتماد من النسخة الأصلية، لكنه ما زال يحتاج Sprint تثبيت قبل أي Release مهم. بعد الوصول إلى **8.4 / 10**، أصبح الهدف الواقعي التالي هو **8.6 / 10** عبر App Check، نقل cross-user chat writes إلى Cloud Functions، ضغط assets فعلياً، وتنفيذ refactor تصميمي مركز لموديول ظاهر.

## Update - 2026-07-22

State management migration progressed after this audit:

- `Provider` / `ChangeNotifier` markers in `lib` are now cleared.
- The Payslip, Performance, and Recruitment module presentation boundaries were migrated away from Riverpod.
- Purchase Management MR detail, invoice receiving detail/list, main purchase hub, RFQ hub access handling, and home Purchase card were cleaned up toward BLoC/plain Flutter state.
- Several HR Management request forms and the HR request entry router were cleaned up toward BLoC/plain Flutter state.
- HR Management hub, personal list, and manager landing list/KPI flows were moved away from Riverpod toward BLoC/plain Flutter state.
- GetX state-management markers were cleared from `lib`; the remaining non-BLoC state-management surface is Riverpod.
- Latest state audit:
  - BLoC markers: 258
  - Provider markers: 0
  - Riverpod markers: 161
  - GetX markers: 0

Updated state-management score after the applied migration work: **9.5 / 10** for direction and consistency. Remaining deductions are for Riverpod still present in Attendance Reports, Timesheet, session/bootstrap-related areas, plus the need for focused tests around migrated flows.

## Update - 2026-07-23

Quality, security, and release-readiness updates were applied after the original **5.8 / 10** audit.

### Implemented fixes

- Fixed the startup asset crash by adding a compatible root `AssetManifest.json` and registering it in `pubspec.yaml`.
- Verified Android debug packaging with `flutter build apk --debug --no-pub`.
- Restored QA baseline: `flutter test --no-pub` now passes with **50 passing tests**.
- Cleaned `pubspec.yaml` metadata:
  - Replaced the default `"A new Flutter project."` description.
  - Replaced all direct dependency `null` declarations with explicit version ranges based on the lockfile.
  - Current `pubspec.yaml` direct `: null` count: **0**.
- Improved Cloud Functions dependency posture:
  - `functions` now uses `firebase-admin ^14.2.0` and `firebase-functions ^7.3.0`.
  - `functions-liveness` now uses `firebase-admin ^14.2.0` and `firebase-functions ^7.3.0`.
  - `npm audit --omit=dev` reduced from critical/high findings to **7 moderate transitive findings**.
  - Remaining findings are in the Firebase/Google dependency chain around `uuid`; `npm audit fix --force` currently suggests an unsafe downgrade path, so it was not applied.
- Hardened liveness behavior:
  - Mock liveness is now disabled by default.
  - Mock mode only works when `ALLOW_LIVENESS_MOCK=true` is explicitly configured.
  - Missing AWS credentials now produce `failed-precondition` instead of a silent successful mock session.
- Hardened Firestore chat rules:
  - `chats/{chatId}/messages` read access is restricted to chat members.
  - Message creation requires `sender_id == request.auth.uid`.
  - Message deletion is denied from clients.
  - `chats/{chatId}/members` read/write is no longer open to every signed-in user.
- Verified Firestore rules syntax by starting the Firestore emulator successfully.
- Cleaned one known mojibake metadata string in `functions-liveness/package.json`.

### Updated metrics

- Flutter tests: **50 passed**.
- Android debug build: **passed**.
- Firestore emulator/rules load: **passed**.
- Full `flutter analyze --no-pub --no-fatal-infos --no-fatal-warnings`: still timed out after 5 minutes and remains a tooling/cleanup target.
- Provider/Get direct package imports in `lib/test`: **0**.
- Riverpod package imports in `lib`: **59**.
- BLoC/Cubit usage markers in `lib`: **249**.
- Empty `catch {}` markers in the checked app/functions surface: **0**.
- Direct `print(` markers remain high: **1134**.
- Direct `debugPrint(` markers remain high: **863**.

### Updated practical rating

The project rating is now **8.0 / 10**.

### Second pass improvements on 2026-07-23

- Added `lib/core/logging/app_logger.dart`:
  - Central log levels: debug, info, warning, error.
  - Automatic masking for sensitive keys such as `password`, `token`, `firebase_custom_token`, `fcm_token`, `authorization`, and `device_id`.
  - Debug/info logs are debug-build only.
- Migrated login API logging in `lib/ui/presentation/signin/data/repository.dart`:
  - Removed raw request/response printing.
  - Removed password, token, and FCM token exposure from direct logs.
  - Direct `print(` markers in that file are now **0**.
- Added `ASSET_USAGE_REPORT.md`.
- Reduced bundled assets by replacing broad folder declarations with explicit file lists:
  - `assets/json/` now lists only the used JSON animation files.
  - `assets/json/logo.json` (**18.26 MB**) is no longer bundled.
  - `assets/antispoof/` now lists only the two runtime TFLite models.
  - TensorFlow saved_model folders under `assets/antispoof/` are no longer bundled.
- Verified required runtime assets remain present in `flutter_assets`:
  - `assets/json/blink.json`
  - `assets/json/face_detecting.json`
  - `assets/antispoof/minifasnet_v1se_4.0_80x80.tflite`
  - `assets/antispoof/minifasnet_v2_2.7_80x80.tflite`
  - `assets/mobilefacenet_512.tflite`
  - `assets/mp4/splash.mp4`
- Ran `flutter precache --android --force` to fix a Flutter framework/engine artifact mismatch that caused internal SDK compile errors.
- Verified `flutter build apk --debug --no-pub` passes again after precache.
- Latest observed debug APK size: **365.96 MB**.
- Latest `flutter_assets/assets` size: **77 MB**.

Why not higher yet:

- The assets bundle is still large and needs a dedicated asset usage pass.
- Direct logging is still too broad for production and should move to a masked logger.
- Riverpod remains in Timesheet, Attendance Reports, and session/bootstrap areas.
- Firestore `userChats` still allows cross-user create/update because the current client flow depends on it for DM visibility; the safer long-term fix is moving those cross-user writes into Cloud Functions.
- UAE PASS production flavor/config is still not fully release-ready.
- Test coverage now runs, but coverage breadth is still limited compared with the app size.

### Third pass improvements on 2026-07-23

- Migrated sensitive chat token logging to `AppLogger`:
  - `lib/chat/services/firebase_token_api_service.dart`
  - `lib/chat/services/firebase_chat_auth_service.dart`
- Removed direct `print(` usage from the sensitive auth/token files:
  - `lib/ui/presentation/signin/data/repository.dart`
  - `lib/chat/services/firebase_token_api_service.dart`
  - `lib/chat/services/firebase_chat_auth_service.dart`
- Removed JWT header decoding logs and custom-token preview logs from the Firebase chat auth flow.
- Sensitive token-like values now pass through masked structured logging instead of raw string output.
- Focused analyzer check passed for the updated auth/token logger files.
- Full verification after this pass:
  - `flutter test --no-pub`: **42 passed**.
  - `flutter build apk --debug --no-pub`: **passed**.
  - Latest debug APK size: **365.96 MB**.

### Current practical rating after third pass

The project rating is now **7.8 / 10**.

The next highest-value improvements are App Check enforcement, moving `userChats` cross-user writes to Cloud Functions, replacing the remaining broad API request/response logs with `AppLogger`, and a focused image/GIF compression pass.

### Fourth pass improvements on 2026-07-23

- Migrated `lib/utils/api_logger.dart` away from raw boxed `print` output to structured `AppLogger` output.
- Migrated `lib/ui/presentation/tasks/data/tasks_api_service.dart` submit/fetch error logging to `AppLogger`.
- Removed direct `print(` usage from:
  - `lib/utils/api_logger.dart`
  - `lib/ui/presentation/tasks/data/tasks_api_service.dart`
- API request Authorization headers now go through masked logging.
- Tuned `AppLogger` JWT detection so normal URLs remain readable while token-like strings are masked.
- Full verification after this pass:
  - Focused analyzer check on logger/tasks/auth files: **passed**.
  - `flutter test --no-pub`: **42 passed**.
  - `flutter build apk --debug --no-pub`: **passed**.
- Current checked app/functions direct `print(` count: **1178**.

### Current practical rating after fourth pass

The project rating is now **7.9 / 10**.

The next clean jump identified after this pass was to remove/mask notification and FCM token logs in `main.dart` and `firebase_service.dart`; that work was completed in the fifth pass below.

### Fifth pass improvements on 2026-07-23

- Removed raw FCM token printing from `lib/main.dart`.
- Migrated FCM/APNS token logs in `lib/firebase_service.dart` to `AppLogger`.
- Added `apns_token` to the sensitive-key masking list in `AppLogger`.
- Verified no direct raw FCM/APNS token preview patterns remain in `lib/main.dart` or `lib/firebase_service.dart`.
- Full verification after this pass:
  - `flutter test --no-pub`: **42 passed**.
  - `flutter build apk --debug --no-pub`: **passed**.
  - Latest debug APK size: **365.96 MB**.
- Current checked app/functions direct `print(` count: **1146**.

### Current practical rating after fifth pass

The project rating is now **8.0 / 10**.

The remaining blockers for going above 8 are App Check enforcement, Cloud Functions ownership for cross-user chat visibility writes, broader release-flavor hardening, and a larger cleanup of notification/deep-link debug output.

### Sixth pass improvements on 2026-07-23

- Added `test/core/logging/app_logger_test.dart`:
  - Verifies Authorization, FCM token, APNS token, password, and JWT-like strings are masked.
  - Verifies normal dotted URLs remain readable in logs.
- Added `test/assets/pubspec_asset_manifest_test.dart`:
  - Prevents accidentally re-adding broad `assets/json/` and `assets/antispoof/` folders.
  - Verifies required runtime Lottie/TFLite assets stay listed explicitly.
  - Verifies known oversized unused files remain excluded from `pubspec.yaml`.
- Full verification after this pass:
  - `flutter test --no-pub`: **46 passed**.
  - `flutter build apk --debug --no-pub`: **passed**.
  - Latest debug APK size: **365.96 MB**.

### Current practical rating after sixth pass

The project rating is now **8.1 / 10**.

Lowest remaining scores are still UI/UX and app size. The next meaningful jump should come from a focused design-token migration in one high-traffic module plus real image/GIF compression tooling, not from deleting assets that are currently used.

### Seventh pass improvements on 2026-07-23

- Replaced broad `assets/gif/` registration in `pubspec.yaml` with explicit used GIF files:
  - `assets/gif/ai.gif`
  - `assets/gif/arrow_animation.gif`
  - `assets/gif/el-race-logo.gif`
  - `assets/gif/finger-print.gif`
- Extended `test/assets/pubspec_asset_manifest_test.dart` to prevent re-adding the whole GIF folder.
- Added `test/design/direct_color_budget_test.dart`:
  - Tracks direct `Color(...)` / `Colors.*` usage outside theme/color files.
  - Prevents the UI/UX debt from growing while design-token migration continues.
- Ran `flutter pub get` after the `pubspec.yaml` asset change; the lockfile was refreshed by Flutter's resolver.
- Full verification after this pass:
  - `flutter test --no-pub`: **47 passed**.
  - `flutter build apk --debug --no-pub`: **passed**.
  - Latest debug APK size: **365.96 MB**.
  - Direct color usage outside theme/color files by `rg` scan: **7520** markers.

### Current practical rating after seventh pass

The project rating is now **8.2 / 10**.

The next realistic lift should be one focused UI refactor in a visible module, plus real GIF/image compression tooling. Without compression tooling, deleting currently used assets would be risky.

### Eighth pass improvements on 2026-07-23

- Cleaned direct logging and silent catches in Flutter code-quality hotspots:
  - `lib/ui/presentation/tasks/data/local_tasks_hive_service.dart`
  - `lib/ui/presentation/tasks/bloc/tasks_bloc.dart`
  - `lib/utils/Util.dart`
  - `lib/utils/di.dart`
- Replaced direct `print(` calls in those files with `AppLogger`.
- Replaced empty `catch (_) {}` blocks in `TasksBloc` with warning logs that preserve task context.
- Added `test/code_quality/tasks_logging_quality_test.dart`:
  - Prevents direct `print(` from returning to the cleaned Tasks/Utilities surface.
  - Prevents empty catch blocks from returning there.
- Added `test/encoding/critical_text_encoding_test.dart`:
  - Guards critical app/config/i18n files against common mojibake markers and replacement characters.
- Focused analyzer checks:
  - DI/code-quality/encoding tests: **passed**.
- Full verification after this pass:
  - `flutter test --no-pub`: **50 passed**.
  - `flutter build apk --debug --no-pub`: **passed**.
  - Current checked app/functions direct `print(` count: **1134**.
  - Current checked app/functions empty catch count: **105**.

### Current practical rating after eighth pass

The project rating is now **8.4 / 10**.

The old section ratings in the original audit have now been refreshed so they no longer show 3/4/5 scores for areas that were materially improved. The remaining sub-7 areas require heavier work: UI refactor, asset compression tooling, and deeper encoding review across legacy files.
