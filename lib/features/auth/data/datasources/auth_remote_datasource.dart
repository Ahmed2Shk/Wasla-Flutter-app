import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_requests.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> register(RegisterRequest request);
  Future<Map<String, dynamic>> login(LoginRequest request);
  Future<Map<String, dynamic>> verifyPhone(VerifyOtpRequest request);
  Future<void> sendOtp(SendOtpRequest request);
  Future<void> resetPassword(ResetPasswordRequest request);
  Future<void> setPin(SetPinRequest request);
  Future<Map<String, dynamic>> pinLogin(VerifyPinRequest request);
  Future<void> disablePin();
  Future<void> logout(String refreshToken);
  Future<Map<String, dynamic>> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final res = await dio.post(ApiConstants.register, data: request.toJson());
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    final res = await dio.post(ApiConstants.login, data: request.toJson());
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verifyPhone(VerifyOtpRequest request) async {
    final res = await dio.post(ApiConstants.verifyPhone, data: request.toJson());
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<void> sendOtp(SendOtpRequest request) async {
    await dio.post(ApiConstants.otpSend, data: request.toJson());
  }

  @override
  Future<void> resetPassword(ResetPasswordRequest request) async {
    await dio.post(ApiConstants.passwordReset, data: request.toJson());
  }

  @override
  Future<void> setPin(SetPinRequest request) async {
    await dio.post(ApiConstants.pinSet, data: request.toJson());
  }

  @override
  Future<Map<String, dynamic>> pinLogin(VerifyPinRequest request) async {
    final res = await dio.post(ApiConstants.pinLogin, data: request.toJson());
    return res.data as Map<String, dynamic>;
  }

  @override
  Future<void> disablePin() async {
    await dio.delete(ApiConstants.pinDisable);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await dio.post(ApiConstants.logout, data: {'refreshToken': refreshToken});
  }

  @override
  Future<Map<String, dynamic>> me() async {
    final res = await dio.get(ApiConstants.me);
    return res.data as Map<String, dynamic>;
  }
}
