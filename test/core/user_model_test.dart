import 'package:flutter_test/flutter_test.dart';
import 'package:wasla_app/core/models/enums.dart';
import 'package:wasla_app/core/models/user.dart';

/// AuthResponse الحقيقي من الباك اند (تسجيل الدخول / verify-phone / pin-login)
/// شكله: { accessToken, refreshToken, accessTokenExpiresAt, userId, name,
/// userType, isPhoneVerified, hasPinSet } — بدون "user" wrapper، وبمفتاح
/// "userId" مش "id"، وبدون phoneNumber/email إطلاقاً.
void main() {
  test('User.fromJson بيقرأ شكل AuthResponse الحقيقي (userId + userType رقم)', () {
    final json = {
      'accessToken': 'xyz',
      'refreshToken': 'abc',
      'accessTokenExpiresAt': '2026-01-01T00:00:00Z',
      'userId': 42,
      'name': 'أحمد',
      'userType': 2, // Merchant
      'isPhoneVerified': true,
      'hasPinSet': false,
    };

    final user = User.fromJson(json);

    expect(user.id, 42);
    expect(user.name, 'أحمد');
    expect(user.type, UserType.merchant);
    expect(user.isPhoneVerified, isTrue);
    expect(user.hasPinSet, isFalse);
    // مش موجودين بالرد أصلاً — لازم يرجعوا فاضي/null بهدوء، مش استثناء
    expect(user.phoneNumber, '');
    expect(user.email, isNull);
  });

  test('يقبل "id" كبديل احتياطي (لو مصدر تاني زي /auth/me رجعها بهالاسم)', () {
    final user = User.fromJson({'id': 7, 'userType': 1});
    expect(user.id, 7);
    expect(user.type, UserType.buyer);
  });

  test('copyWith بيحدّث phoneNumber بدون ما يأثر على باقي الحقول', () {
    final user = User(id: 1, name: 'سارة', phoneNumber: '', type: UserType.buyer);
    final updated = user.copyWith(phoneNumber: '0599111222');

    expect(updated.phoneNumber, '0599111222');
    expect(updated.name, 'سارة');
    expect(updated.id, 1);
  });
}
