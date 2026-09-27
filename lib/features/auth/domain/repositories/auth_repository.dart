import '../../../../core/models/user.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/utils/either.dart';
import '../../data/models/auth_requests.dart';

abstract class AuthRepository {
  Future<Either<AppFailure, String>> register(RegisterRequest request);
  Future<Either<AppFailure, User>> login(LoginRequest request);
  Future<Either<AppFailure, User>> verifyPhone(VerifyOtpRequest request);
  Future<Either<AppFailure, void>> sendOtp(SendOtpRequest request);
  Future<Either<AppFailure, void>> resetPassword(ResetPasswordRequest request);
  Future<Either<AppFailure, void>> setPin(String pin);
  Future<Either<AppFailure, User>> pinLogin(String pin);
  Future<Either<AppFailure, void>> disablePin();
  Future<Either<AppFailure, void>> logout();
  Future<Either<AppFailure, User>> fetchMe();
}
