/// عدّل هاد الرابط حسب مكان تشغيل الـ API عندك:
/// - المحاكي Android (Emulator) وبتشغل API على نفس الجهاز: استخدم 10.0.2.2
/// - جهاز حقيقي على نفس الشبكة: استخدم IP جهاز الكمبيوتر (مثال: 192.168.1.5)
/// - سيرفر منشور: استخدم دومين السيرفر مباشرة
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://10.0.2.2:7129'; // غيّر البورت حسب launchSettings.json عندك

  // ---- Auth (مطابق لـ AuthController: [Route("api/auth")]) ----
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String logout = '/api/auth/logout';
  static const String verifyPhone = '/api/auth/verify-phone';
  static const String me = '/api/auth/me';

  // ---- OTP (مطابق لـ OtpController: [Route("api/otp")]) ----
  static const String otpSend = '/api/otp/send';

  // ---- Password (مطابق لـ PasswordController: [Route("api/password")]) ----
  static const String passwordReset = '/api/password/reset';

  // ---- PIN (مطابق لـ PinController: [Route("api/pin")]) ----
  static const String pinSet = '/api/pin/set';
  static const String pinLogin = '/api/pin/login';
  static const String pinDisable = '/api/pin'; // DELETE

  // ---- Profile (لسا فاضي بالباك اند - ProfileController مش مبني بعد) ----
  static const String profile = '/api/profile';
  static const String profileUpdate = '/api/profile/update';

  // ---- Admin (لسا مش موجودة بالباك اند - جاهزة للربط لما تبنيها) ----
  static const String adminStats = '/api/admin/stats';
  static const String adminUsers = '/api/admin/users';
  static const String adminOrders = '/api/admin/orders';

  // ---- Merchant / Buyer (لسا مش موجودة بالباك اند - جاهزة للربط) ----
  static const String merchants = '/api/merchants';
  static const String products = '/api/products';
  static const String orders = '/api/orders';
  static const String cart = '/api/cart';
  static const String wallet = '/api/wallet';
}
