import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_manager.dart';

/// يضيف التوكن لكل Request، ويعالج 401 بتجديد التوكن تلقائياً وإعادة إرسال الطلب.
class AuthInterceptor extends Interceptor {
  final TokenManager tokenManager;

  /// نسخة Dio منفصلة بدون هذا الـ interceptor — لتفادي حلقة لا نهائية وقت الـ refresh
  final Dio _plainDio;

  /// يُستدعى لما التجديد يفشل نهائياً (لإعادة توجيه المستخدم لشاشة الدخول)
  void Function()? onSessionExpired;

  AuthInterceptor(this.tokenManager, {Dio? plainDio})
      : _plainDio = plainDio ?? Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // لا تضف Authorization لطلبات تسجيل الدخول/التسجيل نفسها
    final isPublic = _publicPaths.any((p) => options.path.contains(p));
    if (!isPublic) {
      final token = await tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // 401 من نقطة عامة (تسجيل دخول، PIN، إلخ) معناه "بيانات غلط"، مش "جلسة منتهية" —
    // لازم يمر برسالته الحقيقية القادمة من السيرفر بدون أي محاولة تجديد توكن.
    // بدون هالفحص، إدخال باسورد أو PIN غلط كان بيستهلك/يدوّر الـ refresh token
    // بصمت بكل محاولة فاشلة، رغم إنه ما إله علاقة بانتهاء الجلسة إطلاقاً.
    final isPublic = _publicPaths.any((p) => err.requestOptions.path.contains(p));
    if (isPublic) {
      return handler.next(err);
    }

    final refreshed = await tokenManager.refreshSession((rt) async {
      try {
        final response = await _plainDio.post(
          ApiConstants.refreshToken,
          data: {'refreshToken': rt},
        );
        await tokenManager.saveTokens(
          accessToken: response.data['accessToken'],
          refreshToken: response.data['refreshToken'],
        );
        return true;
      } catch (_) {
        return false;
      }
    });

    if (!refreshed) {
      await tokenManager.clear();
      onSessionExpired?.call();
      return handler.next(err);
    }

    // أعد إرسال الطلب الأصلي بالتوكن الجديد
    try {
      final newToken = await tokenManager.getAccessToken();
      err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
      final retried = await _plainDio.fetch(err.requestOptions);
      handler.resolve(retried);
    } catch (e) {
      handler.next(err);
    }
  }

  static const _publicPaths = [
    ApiConstants.login,
    ApiConstants.register,
    ApiConstants.refreshToken,
    ApiConstants.verifyPhone,
    ApiConstants.otpSend,
    ApiConstants.passwordReset,
    ApiConstants.pinLogin,
  ];
}
