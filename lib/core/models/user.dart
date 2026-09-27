import 'enums.dart';

class User {
  final int id;
  final String name;
  final String? email;
  final String phoneNumber;
  final UserType type;
  final String? city;
  final String? area;
  final String? street;
  final String? landmark;
  final bool isPhoneVerified;
  final bool hasPinSet;

  User({
    required this.id,
    required this.name,
    this.email,
    required this.phoneNumber,
    required this.type,
    this.city,
    this.area,
    this.street,
    this.landmark,
    this.isPhoneVerified = false,
    this.hasPinSet = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      // AuthResponse (تسجيل الدخول/OTP/PIN) بترجع "userId"، بينما /auth/me ممكن يرجع "id"
      id: json['id'] ?? json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? '',
      type: UserType.fromApiString(json['type'] ?? json['userType']),
      city: json['city'],
      area: json['area'],
      street: json['street'],
      landmark: json['landmark'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      hasPinSet: json['hasPinSet'] ?? false,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? phoneNumber,
    String? city,
    String? area,
    String? street,
    String? landmark,
    bool? hasPinSet,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      type: type,
      city: city ?? this.city,
      area: area ?? this.area,
      street: street ?? this.street,
      landmark: landmark ?? this.landmark,
      isPhoneVerified: isPhoneVerified,
      hasPinSet: hasPinSet ?? this.hasPinSet,
    );
  }
}
