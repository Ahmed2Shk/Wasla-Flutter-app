import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/token_manager.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create(TokenManager tokenManager, {void Function()? onSessionExpired}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept-Language': 'ar',
        },
        // بيئة التطوير فقط: لو عندك شهادة HTTPS محلية (dev cert) وبيرفض الاتصال،
        // فعّل هاد مؤقتاً. لا تستخدمه بالإنتاج.
        // validateStatus: (status) => status != null && status < 500,
      ),
    );

    final interceptor = AuthInterceptor(tokenManager)
      ..onSessionExpired = onSessionExpired;
    dio.interceptors.add(interceptor);

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true, error: true),
      );
    }

    return dio;
  }
}
