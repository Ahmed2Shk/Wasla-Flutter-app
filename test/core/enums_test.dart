import 'package:flutter_test/flutter_test.dart';
import 'package:wasla_app/core/models/enums.dart';

/// هاد التست بيثبّت القيم الرقمية الحقيقية يلي مؤكدة من الباك اند
/// (Wasla.Models.Enums.UserType / OtpPurpose) — لو حدا غيّرها بالغلط
/// بالمستقبل (رجعها لـ 0-based مثلاً)، هاد التست بيفشل فوراً بدل ما
/// يكتشف المشكلة بعد ما يوصل خطأ "JSON value could not be converted"
/// من السيرفر وقت التشغيل الفعلي.
void main() {
  group('UserType.apiValue (القيمة يلي تنبعت للسيرفر)', () {
    test('buyer = 1', () => expect(UserType.buyer.apiValue, 1));
    test('merchant = 2', () => expect(UserType.merchant.apiValue, 2));
    test('admin = 3', () => expect(UserType.admin.apiValue, 3));
  });

  group('UserType.fromApiString (قراءة الرد القادم من السيرفر)', () {
    test('يقرأ الأرقام الصحيحة (1/2/3)', () {
      expect(UserType.fromApiString(1), UserType.buyer);
      expect(UserType.fromApiString(2), UserType.merchant);
      expect(UserType.fromApiString(3), UserType.admin);
    });

    test('يقرأ النصوص كبديل احتياطي (لو السيرفر أرجع string يوماً)', () {
      expect(UserType.fromApiString('Buyer'), UserType.buyer);
      expect(UserType.fromApiString('Merchant'), UserType.merchant);
      expect(UserType.fromApiString('Admin'), UserType.admin);
    });

    test('قيمة غير معروفة أو null بترجع buyer كافتراضي آمن (مش استثناء)', () {
      expect(UserType.fromApiString(null), UserType.buyer);
      expect(UserType.fromApiString(999), UserType.buyer);
      expect(UserType.fromApiString('شيء غريب'), UserType.buyer);
    });

    test('round-trip: apiValue ثم fromApiString بيرجع لنفس القيمة', () {
      for (final type in UserType.values) {
        expect(UserType.fromApiString(type.apiValue), type);
      }
    });
  });

  group('OtpPurpose.value (القيمة يلي تنبعت للسيرفر)', () {
    test('registration = 1', () => expect(OtpPurpose.registration.value, 1));
    test('forgotPassword = 2', () => expect(OtpPurpose.forgotPassword.value, 2));
    test('changePhoneNumber = 3', () => expect(OtpPurpose.changePhoneNumber.value, 3));
  });
}
