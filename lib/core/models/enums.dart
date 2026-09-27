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

  /// القيمة الرقمية يلي لازم تنبعت للباك اند (System.Text.Json عندك ما فيه
  /// JsonStringEnumConverter، فبيتوقع رقم enum مش نص — أكّدنا هيك من رسالة الخطأ
  /// "The JSON value could not be converted to Wasla.Models.Enums.UserType").
  /// ✅ مؤكدة من الباك اند فعلياً: Buyer=1, Merchant=2, Admin=3
  int get apiValue {
    switch (this) {
      case UserType.buyer:
        return 1;
      case UserType.merchant:
        return 2;
      case UserType.admin:
        return 3;
    }
  }

  /// يقبل String ('Buyer'/'Merchant'/'Admin') أو int (1/2/3، مؤكدة من الباك اند) —
  /// لأنه System.Text.Json ممكن يرجع الـ enum بأي شكل من الشكلين حسب إعدادات السيرفر
  static UserType fromApiString(dynamic value) {
    if (value is int) {
      switch (value) {
        case 2:
          return UserType.merchant;
        case 3:
          return UserType.admin;
        case 1:
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

/// مطابق لـ OtpPurpose بالباك اند — مؤكدة فعلياً: registration=1, forgotPassword=2, changePhoneNumber=3
enum OtpPurpose {
  registration(1),
  forgotPassword(2),
  changePhoneNumber(3);

  final int value;
  const OtpPurpose(this.value);
}

enum AuthStatus { unknown, unauthenticated, needsPin, authenticated }
