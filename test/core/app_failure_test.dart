import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wasla_app/core/errors/app_failure.dart';

/// الباك اند فعلياً بيرجع 3 أشكال مختلفة من الأخطاء (شفناها بالكود الحقيقي):
/// 1) أخطاء منطق العمل (AppException → ExceptionHandlingMiddleware):
///    { "success": false, "message": "..." } — بدون "errors" إطلاقاً
/// 2) أخطاء FluentValidation (ValidationFilter المخصص):
///    { "success": false, "message": "بيانات المدخلات غير صالحة", "errors": {...} }
/// 3) أخطاء ربط JSON التلقائية من [ApiController] (مثلاً enum غلط):
///    { "title": "...", "status": 400, "errors": {...} } — بدون "success" ولا "message"!
/// AppFailure لازم يتعامل صح مع الثلاثة أشكال بدون ما يطلع "حدث خطأ غير متوقع"
/// لأي واحد فيهم طالما الرد نفسه وصل بنجاح.
void main() {
  RequestOptions _req() => RequestOptions(path: '/api/test');

  DioException _dioError({required int statusCode, required dynamic data}) {
    final req = _req();
    return DioException(
      requestOptions: req,
      response: Response(requestOptions: req, statusCode: statusCode, data: data),
      type: DioExceptionType.badResponse,
    );
  }

  group('شكل 1: أخطاء منطق العمل (بدون errors)', () {
    test('يعرض message الحقيقي القادم من السيرفر، وfieldErrors تكون null', () {
      final failure = AppFailure.fromDioException(_dioError(
        statusCode: 401,
        data: {'success': false, 'message': 'رقم الهاتف أو كلمة المرور غير صحيحة'},
      ));
      expect(failure.message, 'رقم الهاتف أو كلمة المرور غير صحيحة');
      expect(failure.fieldErrors, isNull);
      expect(failure.statusCode, 401);
    });
  });

  group('شكل 2: أخطاء FluentValidation (مع errors)', () {
    test('يلتقط message العام وfieldErrors سوا', () {
      final failure = AppFailure.fromDioException(_dioError(
        statusCode: 400,
        data: {
          'success': false,
          'message': 'بيانات المدخلات غير صالحة',
          'errors': {
            'phoneNumber': ['رقم الهاتف غير صحيح'],
            'password': ['كلمة المرور مطلوبة'],
          },
        },
      ));
      expect(failure.message, 'بيانات المدخلات غير صالحة');
      expect(failure.errorFor('phoneNumber'), 'رقم الهاتف غير صحيح');
      expect(failure.errorFor('password'), 'كلمة المرور مطلوبة');
      // errorFor لازم يكون case-insensitive (فائدة عملية: أسماء الحقول
      // بتوصل camelCase من السيرفر بينما بعض الشاشات ممكن تبحث بأي حالة أحرف)
      expect(failure.errorFor('PhoneNumber'), 'رقم الهاتف غير صحيح');
      // حقل غير موجود بالأخطاء يرجع null بهدوء بدون استثناء
      expect(failure.errorFor('city'), isNull);
    });

    test('displayMessage بيدمج تفاصيل الحقول بدل الرسالة العامة غير المفيدة', () {
      // هاد بالضبط الباگ يلي انصلح: كل الشاشات (login/verifyPhone/setPin/pinLogin/
      // forgot-password) كانت تعرض بس "message" العام وتفقد هالتفاصيل بالكامل
      final failure = AppFailure.fromDioException(_dioError(
        statusCode: 400,
        data: {
          'success': false,
          'message': 'بيانات المدخلات غير صالحة',
          'errors': {
            'phoneNumber': ['رقم الهاتف غير صحيح'],
          },
        },
      ));
      expect(failure.displayMessage, contains('رقم الهاتف غير صحيح'));
      expect(failure.displayMessage, isNot(contains('بيانات المدخلات غير صالحة')));
    });
  });

  group('displayMessage بدون fieldErrors', () {
    test('يرجع نفس message العام (ما فيه تفاصيل أصلاً ليدمجها)', () {
      final failure = AppFailure.fromDioException(_dioError(
        statusCode: 401,
        data: {'success': false, 'message': 'رقم الهاتف أو كلمة المرور غير صحيحة'},
      ));
      expect(failure.displayMessage, 'رقم الهاتف أو كلمة المرور غير صحيحة');
    });
  });

  group('شكل 3: أخطاء ربط JSON التلقائية من [ApiController]', () {
    test('يستخدم title كـ message لما message نفسها مش موجودة', () {
      final failure = AppFailure.fromDioException(_dioError(
        statusCode: 400,
        data: {
          'title': 'One or more validation errors occurred.',
          'status': 400,
          'errors': {
            'userType': ['The JSON value could not be converted to Wasla.Models.Enums.UserType.'],
          },
        },
      ));
      expect(failure.message, 'One or more validation errors occurred.');
      expect(failure.errorFor('userType'), contains('UserType'));
    });
  });

  group('أخطاء الشبكة (بدون رد من السيرفر إطلاقاً)', () {
    test('انتهاء مهلة الاتصال بيعطي رسالة عربية واضحة', () {
      final req = _req();
      final failure = AppFailure.fromDioException(DioException(
        requestOptions: req,
        type: DioExceptionType.connectionTimeout,
      ));
      expect(failure.message, contains('مهلة الاتصال'));
    });

    test('تعذر الاتصال (لا إنترنت / سيرفر مطفي) بيعطي رسالة عربية واضحة', () {
      final req = _req();
      final failure = AppFailure.fromDioException(DioException(
        requestOptions: req,
        type: DioExceptionType.connectionError,
      ));
      expect(failure.message, contains('تعذر الاتصال'));
    });
  });
}
