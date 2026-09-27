import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
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
      ),
    );

    // بيئة التطوير فقط: ASP.NET Core بيولّد شهادة HTTPS محلية (Self-signed)
    // مش موثوقة من نظام Android، فبيرفض الاتصال بصمت (badCertificate).
    // هاد بيخلي التطبيق يثق فيها وقت التطوير بس — أبداً لا تستخدمه بالإنتاج.
    if (kDebugMode) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

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
