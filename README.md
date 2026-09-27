# وصلة (Wasla) — Flutter App

مشروع Flutter كامل مربوط ببنية الـ ASP.NET Core API يلي بنيتها، مبني على Riverpod + go_router + Dio، بنفس الـ Architecture يلي اتفقنا عليها.

---

## 🚀 كيف تشغّل المشروع (Android Studio)

### 0. ⚠️ خطوة أولى ضرورية — ولّد مجلدات المنصّات (android/ios)
هاد المشروع فيه بس كود Dart (`lib/`) و`pubspec.yaml` — يعني الجزء البرمجي، بدون مجلدات `android/` و`ios/` (هاي بتتولد آلياً وما في داعي نبعتها جاهزة). قبل ما تفتحه بـ Android Studio، افتح Terminal جوا مجلد `wasla_app` ونفّذ:

```bash
flutter create .
```

هاد الأمر رح يولّد مجلدات `android/`, `ios/`, `web/` وغيرها حوالين الكود الموجود، بدون ما يلمس `lib/` أو `pubspec.yaml` (لأنهم موجودين أصلاً). بعدها المشروع جاهز يفتح ويشتغل عادي.

### 1. افتح المشروع
`File → Open` واختر مجلد `wasla_app` (المجلد يلي فيه `pubspec.yaml`).

### 2. نزّل الحزم
```bash
flutter pub get
```
أو من Android Studio: **Pub Get** بالزاوية العلوية لما يفتح `pubspec.yaml`.

### 3. **مهم جداً — اربط رابط الـ API الصحيح**
افتح: `lib/core/constants/api_constants.dart`

```dart
static const String baseUrl = 'https://10.0.2.2:7255';
```

- **محاكي Android (Emulator)** وشغّال الـ API على نفس جهاز الكمبيوتر: خلّي `10.0.2.2` (هاي عنوان خاص بالمحاكي بيشاور على "localhost" تبع جهازك). بس غيّر الـ **port** ليطابق البورت يلي شغّال عليه الـ API عندك (شوف `Properties/launchSettings.json` بمشروع الـ API).
- **جهاز حقيقي** موصول بنفس شبكة الواي فاي: بدّل `10.0.2.2` بالـ IP المحلي لجهاز الكمبيوتر (مثال: `192.168.1.5`)، وتأكد الفايروول مو مانع الاتصال على هذا البورت.
- **سيرفر منشور فعلياً**: حط الدومين مباشرة.

### 4. إعدادات Android الإضافية (مهمة!)

#### أ) صلاحية الإنترنت
افتح `android/app/src/main/AndroidManifest.xml` وتأكد فيه:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
(موجودة افتراضياً بمعظم مشاريع Flutter الجديدة، بس تأكد منها)

#### ب) لو الـ API شغّال على HTTP (مش HTTPS) أثناء التطوير
Android من نسخة 9 وفوق بيرفض HTTP (cleartext) افتراضياً. لو الـ API عندك مش عليه شهادة HTTPS محلياً، ضيف بملف `android/app/src/main/AndroidManifest.xml` جوا `<application>`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```
وبدّل `baseUrl` بالمشروع لـ `http://10.0.2.2:PORT` (بدون s).

#### ج) لو شهادة HTTPS المحلية (dev certificate) بترفض الاتصال
هاي مشكلة شائعة جداً وقت التطوير المحلي مع ASP.NET Core. الحل الأسهل مؤقتاً: استخدم HTTP بدل HTTPS بالتطوير (النقطة ب فوق)، أو فعّل الـ launchSettings تبع الـ API يشتغل بس على HTTP.

### 5. شغّل التطبيق
```bash
flutter run
```

---

## 📁 بنية المشروع

```
lib/
├── core/                          # كل شي مشترك ما بيتغيّر حسب الميزة
│   ├── constants/api_constants.dart   # روابط كل الـ endpoints (مطابقة لكونترولرز الـ API)
│   ├── theme/                         # الألوان والثيم (مأخوذة من التصاميم يلي بعتها)
│   ├── network/                       # Dio + Auth Interceptor (تجديد التوكن تلقائياً)
│   ├── storage/token_manager.dart     # التخزين الآمن للتوكنات + قفل التزامن
│   ├── errors/app_failure.dart        # توحيد شكل الأخطاء القادمة من السيرفر
│   ├── models/                        # User, UserType, OtpPurpose, AuthStatus
│   ├── router/app_router.dart         # كل الـ routes + منطق الحماية والتوجيه
│   └── widgets/                       # أزرار، حقول إدخال، صناديق OTP/PIN مشتركة
│
├── features/
│   ├── auth/                      # التسجيل، الدخول، OTP، PIN، نسيت كلمة المرور
│   │   ├── data/                  # الطلبات (Requests) + الاتصال بالـ API + الـ Repository
│   │   ├── domain/                # عقد الـ Repository (Interface)
│   │   └── presentation/          # الشاشات + AuthStateNotifier (إدارة حالة الجلسة)
│   │
│   ├── buyer/presentation/        # الرئيسية، الطلبات وتتبعها، السلة، دليل الموردين
│   ├── merchant/presentation/     # لوحة التاجر (رصيد، طلبات جديدة، قبول/رفض)
│   ├── admin/presentation/        # لوحة تحكم المسؤول (إحصائيات، إدارة)
│   └── account/presentation/      # إعدادات الحساب (مشتركة لكل الأدوار)
│
└── main.dart                      # نقطة الدخول (Riverpod + GoRouter + Theme)
```

---

## ✅ اللي شغّال فعلياً ومربوط بالـ API الحقيقي

| الميزة | الحالة |
|---|---|
| تسجيل حساب جديد (`/api/auth/register`) | ✅ مربوط فعلياً |
| تسجيل الدخول (`/api/auth/login`) | ✅ مربوط فعلياً |
| التحقق من الهاتف (`/api/auth/verify-phone`) | ✅ مربوط فعلياً |
| تجديد التوكن التلقائي (`/api/auth/refresh-token`) | ✅ مربوط فعلياً (Interceptor) |
| تسجيل الخروج (`/api/auth/logout`) | ✅ مربوط فعلياً |
| إرسال/إعادة إرسال OTP (`/api/otp/send`) | ✅ مربوط فعلياً |
| نسيان كلمة المرور (`/api/password/reset`) | ✅ مربوط فعلياً |
| تفعيل PIN (`/api/pin/set`) | ✅ مربوط فعلياً |
| الدخول بالـ PIN (`/api/pin/login`) | ✅ مربوط فعلياً |
| صفحات المشتري/التاجر/الأدمن (المنتجات، الطلبات، الإحصائيات) | 🟡 UI جاهزة ببيانات تجريبية — لسا بحاجة endpoints مش مبنية عندك بعد (راجع `api_constants.dart`) |

---

## ⚠️ افتراضات لازم تتأكد منها (لأنه ما كان عندي الـ DTOs الفعلية)

كان عندي فقط الـ **Validators** و**Controllers**، ومش الـ DTOs نفسها. فبنيت الكود على افتراض إنه رد `/login` و`/verify-phone` و`/pin/login` يرجع شكل قريب من:
```json
{
  "accessToken": "...",
  "refreshToken": "...",
  "user": { "id": 1, "name": "...", "phoneNumber": "...", "type": "Buyer", ... }
}
```

لو الشكل الفعلي عندك مختلف (مثلاً بيانات اليوزر مو تحت مفتاح `"user"` أو أسماء الحقول مختلفة)، عدّل بس دالة وحدة:
📍 `lib/features/auth/data/repositories/auth_repository_impl.dart` → دالة `_saveTokensAndBuildUser`

وكمان تأكد إنه قيم enum الـ `OtpPurpose` بالسيرفر (Registration/ForgotPassword/ChangePhoneNumber) مرتبة بنفس الترتيب الرقمي يلي حطيته بـ:
📍 `lib/core/models/enums.dart`

---

## 🎨 عن التصميم

بنيت الواجهات (الرئيسية، السلة، الطلبات) مطابقة للقطات الشاشة الداكنة (أخضر + برتقالي) يلي بعتها. أما تصميم "اختيار نوع الحساب" (مشتري / تاجر) بصفحة التسجيل فأخذته من الفيديو يلي بعتوه (كان بألوان فاتحة/كريمية مختلفة كنموذج أولي)، بس طبّقته بنفس هوية "وصلة" الداكنة حتى يكون التطبيق متناسق بصرياً بكل شاشاته. لو تحب تصميم صفحة التسجيل يبقى بالألوان الفاتحة الأصلية، قولّي وأعدّلها.

---

## 📌 خطوات لسا قدامك

1. اربط `baseUrl` الصحيح (فوق).
2. جرّب تسجيل حساب جديد → OTP → تعيين PIN → دخول كامل، وتأكد الشكل يطابق ردود الـ API الفعلية عندك.
3. لما تبني endpoints المنتجات/الطلبات/المحفظة الحقيقية بالباك اند، بدّل البيانات التجريبية بـ `FutureProvider` يقرأ من `ApiConstants.products` وهيك (كل الروابط جاهزة بـ `api_constants.dart` تحت تعليق "لسا مش موجودة بالباك اند").
4. لو حابب تضيف Freezed/json_serializable لاحقاً للـ models بدل الكتابة اليدوية، الكود الحالي بسيط قصداً حتى يشتغل فوراً بدون `build_runner`.

بالتوفيق! 🚀
