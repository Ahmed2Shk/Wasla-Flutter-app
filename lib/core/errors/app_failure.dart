import 'package:dio/dio.dart';

/// مطابق لشكل الاستجابة من UseAppExceptionHandling بالباك اند:
/// { "success": false, "message": "...", "errors": { "PhoneNumber": ["..."] } }
class AppFailure {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  final int? statusCode;

  AppFailure(this.message, {this.fieldErrors, this.statusCode});

  /// أول رسالة خطأ لحقل معيّن (لعرضها تحت الـ TextField مباشرة)
  String? errorFor(String field) {
    if (fieldErrors == null) return null;
    final key = fieldErrors!.keys.firstWhere(
      (k) => k.toLowerCase() == field.toLowerCase(),
      orElse: () => '',
    );
    if (key.isEmpty) return null;
    final list = fieldErrors![key];
    return (list != null && list.isNotEmpty) ? list.first : null;
  }

  /// الرسالة يلي **لازم تُعرض دايماً** للمستخدم — لو فيه أخطاء تفصيلية لكل
  /// حقل (fieldErrors)، بتُدمج وتحل محل الرسالة العامة غير المفيدة
  /// ("بيانات المدخلات غير صالحة" / "One or more validation errors occurred")
  /// بدل ما تختفي. كل شاشة لازم تعرض هاي، مش `message` مباشرة.
  String get displayMessage {
    if (fieldErrors == null || fieldErrors!.isEmpty) return message;
    final details = fieldErrors!.values.expand((v) => v).join('\n');
    return details.isEmpty ? message : details;
  }

  factory AppFailure.fromDioException(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message'] ?? data['title'];
        final rawErrors = data['errors'];
        Map<String, List<String>>? parsed;
        if (rawErrors is Map) {
          parsed = rawErrors.map((key, value) {
            final list = value is List
                ? value.map((e) => e.toString()).toList()
                : <String>[value.toString()];
            return MapEntry(key.toString(), list);
          });
        }
        if (msg != null) {
          return AppFailure(
            msg.toString(),
            fieldErrors: parsed,
            statusCode: e.response?.statusCode,
          );
        }
      }
    } catch (_) {
      // تجاهل — بنكمل على الرسالة الافتراضية تحت
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppFailure('انتهت مهلة الاتصال، تحقق من الشبكة وحاول مجدداً');
      case DioExceptionType.connectionError:
        return AppFailure('تعذر الاتصال بالسيرفر، تحقق من الإنترنت');
      default:
        return AppFailure(
          e.response?.statusCode == 401
              ? 'انتهت صلاحية الجلسة، الرجاء تسجيل الدخول من جديد'
              : 'حدث خطأ غير متوقع، حاول مرة أخرى',
          statusCode: e.response?.statusCode,
        );
    }
  }
}
