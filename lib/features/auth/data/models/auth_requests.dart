import '../../../../core/models/enums.dart';

/// مطابق لـ RegisterRequestValidator: PhoneNumber, Password, UserType, Name, Email, City, Area, Street
class RegisterRequest {
  final String name;
  final String? email;
  final String phoneNumber;
  final String password;
  final UserType userType;
  final String city;
  final String area;
  final String street;
  final String? landmark;

  RegisterRequest({
    required this.name,
    this.email,
    required this.phoneNumber,
    required this.password,
    required this.userType,
    required this.city,
    required this.area,
    required this.street,
    this.landmark,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'password': password,
        'userType': userType.toApiString,
        'city': city,
        'area': area,
        'street': street,
        'landmark': landmark,
      };
}

/// مطابق لـ LoginRequestValidator: PhoneNumber, Password
class LoginRequest {
  final String phoneNumber;
  final String password;

  LoginRequest({required this.phoneNumber, required this.password});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'password': password,
      };
}

/// مطابق لـ VerifyOtpRequestValidator: PhoneNumber, Code, Purpose
class VerifyOtpRequest {
  final String phoneNumber;
  final String code;
  final OtpPurpose purpose;

  VerifyOtpRequest({
    required this.phoneNumber,
    required this.code,
    required this.purpose,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'code': code,
        'purpose': purpose.value,
      };
}

/// مطابق لـ SendOtpRequest (OtpController /send)
class SendOtpRequest {
  final String phoneNumber;
  final OtpPurpose purpose;

  SendOtpRequest({required this.phoneNumber, required this.purpose});

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'purpose': purpose.value,
      };
}

/// مطابق لـ ResetPasswordRequestValidator: PhoneNumber, Code, NewPassword
class ResetPasswordRequest {
  final String phoneNumber;
  final String code;
  final String newPassword;

  ResetPasswordRequest({
    required this.phoneNumber,
    required this.code,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'code': code,
        'newPassword': newPassword,
      };
}

/// مطابق لـ SetPinRequestValidator: Pin (محمي بتوكن، ما بيحتاج refreshToken)
class SetPinRequest {
  final String pin;
  SetPinRequest({required this.pin});
  Map<String, dynamic> toJson() => {'pin': pin};
}

/// مطابق لـ VerifyPinRequestValidator: RefreshToken, Pin
class VerifyPinRequest {
  final String refreshToken;
  final String pin;

  VerifyPinRequest({required this.refreshToken, required this.pin});

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
        'pin': pin,
      };
}

class RefreshTokenRequest {
  final String refreshToken;
  RefreshTokenRequest({required this.refreshToken});
  Map<String, dynamic> toJson() => {'refreshToken': refreshToken};
}
