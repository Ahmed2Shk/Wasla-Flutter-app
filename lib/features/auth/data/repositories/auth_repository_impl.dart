import 'package:dio/dio.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/models/user.dart';
import '../../../../core/storage/token_manager.dart';
import '../../../../core/utils/either.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_requests.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenManager tokenManager;

  AuthRepositoryImpl({required this.remote, required this.tokenManager});

  /// أي رد فيه accessToken/refreshToken لازم يمر من هون فوراً —
  /// هذا الانضباط هو اللي بيمنع مشاكل الـ token rotation
  ///
  /// [fallbackPhoneNumber]: AuthResponse الحقيقي من الباك اند ما بيرجع phoneNumber
  /// (بس accessToken/refreshToken/userId/name/userType/isPhoneVerified/hasPinSet)،
  /// فبنستخدم رقم الهاتف يلي المستخدم كتبه بنفس الطلب حتى ما يضيع من الواجهة.
  Future<User> _saveTokensAndBuildUser(
    Map<String, dynamic> data, {
    String? fallbackPhoneNumber,
  }) async {
    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken != null && refreshToken != null) {
      await tokenManager.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }

    final userJson = data['user'] as Map<String, dynamic>?;
    final user = userJson != null
        ? User.fromJson(userJson)
        // الشكل الفعلي: AuthResponse مسطّح (flat) — بيانات المستخدم بنفس مستوى التوكنات
        : User.fromJson(data);

    if ((user.phoneNumber.isEmpty) && fallbackPhoneNumber != null) {
      return user.copyWith(phoneNumber: fallbackPhoneNumber);
    }
    return user;
  }

  @override
  Future<Either<AppFailure, String>> register(RegisterRequest request) async {
    try {
      final data = await remote.register(request);
      return Right(data['message']?.toString() ?? 'تم إنشاء الحساب بنجاح');
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> login(LoginRequest request) async {
    try {
      final data = await remote.login(request);
      final user = await _saveTokensAndBuildUser(
        data,
        fallbackPhoneNumber: request.phoneNumber,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> verifyPhone(VerifyOtpRequest request) async {
    try {
      final data = await remote.verifyPhone(request);
      final user = await _saveTokensAndBuildUser(
        data,
        fallbackPhoneNumber: request.phoneNumber,
      );
      return Right(user);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, void>> sendOtp(SendOtpRequest request) async {
    try {
      await remote.sendOtp(request);
      return const Right(null);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, void>> resetPassword(ResetPasswordRequest request) async {
    try {
      await remote.resetPassword(request);
      return const Right(null);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, void>> setPin(String pin) async {
    try {
      await remote.setPin(SetPinRequest(pin: pin));
      return const Right(null);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> pinLogin(String pin) async {
    try {
      final rt = await tokenManager.getRefreshToken();
      if (rt == null) {
        return Left(AppFailure('لا توجد جلسة سابقة، الرجاء تسجيل الدخول من جديد'));
      }
      final data = await remote.pinLogin(VerifyPinRequest(refreshToken: rt, pin: pin));
      final user = await _saveTokensAndBuildUser(data);
      return Right(user);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, void>> disablePin() async {
    try {
      await remote.disablePin();
      return const Right(null);
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, void>> logout() async {
    try {
      final rt = await tokenManager.getRefreshToken();
      if (rt != null) {
        await remote.logout(rt);
      }
      await tokenManager.clear();
      return const Right(null);
    } on DioException catch (e) {
      // حتى لو فشل الطلب، امسح التوكن محلياً
      await tokenManager.clear();
      return Left(AppFailure.fromDioException(e));
    }
  }

  @override
  Future<Either<AppFailure, User>> fetchMe() async {
    try {
      final data = await remote.me();
      return Right(User.fromJson(data));
    } on DioException catch (e) {
      return Left(AppFailure.fromDioException(e));
    }
  }
}
