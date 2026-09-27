/// مطابق لـ Wasla.Models.Enums.UserType بالباك اند
enum UserType {
  buyer, // صاحب محل
  merchant, // بركس / موزع
  admin; // مدير النظام

  String get toApiString {
    switch (this) {
      case UserType.buyer:
        return 'Buyer';
      case UserType.merchant:
        return 'Merchant';
      case UserType.admin:
        return 'Admin';
    }
  }

  /// يقبل String ('Buyer'/'Merchant'/'Admin') أو int (0/1/2) —
  /// لأنه System.Text.Json ممكن يرجع الـ enum بأي شكل من الشكلين حسب إعدادات السيرفر
  static UserType fromApiString(dynamic value) {
    if (value is int) {
      switch (value) {
        case 1:
          return UserType.merchant;
        case 2:
          return UserType.admin;
        case 0:
        default:
          return UserType.buyer;
      }
    }
    switch (value?.toString()) {
      case 'Merchant':
        return UserType.merchant;
      case 'Admin':
        return UserType.admin;
      case 'Buyer':
      default:
        return UserType.buyer;
    }
  }

  String get arabicLabel {
    switch (this) {
      case UserType.buyer:
        return 'مشتري';
      case UserType.merchant:
        return 'تاجر / مورد';
      case UserType.admin:
        return 'مدير النظام';
    }
  }
}

/// مطابق لـ OtpPurpose بالباك اند (رتّب القيم الرقمية حسب enum السيرفر عندك بالضبط)
enum OtpPurpose {
  registration(0),
  forgotPassword(1),
  changePhoneNumber(2);

  final int value;
  const OtpPurpose(this.value);
}

enum AuthStatus { unknown, unauthenticated, needsPin, authenticated }
