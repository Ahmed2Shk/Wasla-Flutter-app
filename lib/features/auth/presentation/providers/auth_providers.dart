import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/models/user.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/token_manager.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/auth_requests.dart';

// ---------------------------------------------------------------------------
// Infra Providers (مشتركة لكل الـ features)
// ---------------------------------------------------------------------------

final Provider<TokenManager> tokenManagerProvider = Provider<TokenManager>((ref) {
  return TokenManager(const FlutterSecureStorage());
});

final Provider<Dio> dioProvider = Provider<Dio>((ref) {
  final tokenManager = ref.watch(tokenManagerProvider);
  return DioClient.create(
    tokenManager,
    onSessionExpired: () {
      // لما التجديد يفشل نهائياً، رجّع المستخدم لحالة "غير مسجل"
      ref.read(authStateNotifierProvider.notifier).forceLogout();
    },
  );
});

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    tokenManager: ref.watch(tokenManagerProvider),
  );
});

// ---------------------------------------------------------------------------
// Auth State
// ---------------------------------------------------------------------------

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  UserType? get role => user?.type;
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  final TokenManager _tokenManager;

  AuthStateNotifier(this._repo, this._tokenManager) : super(const AuthState());

  /// يُستدعى عند بدء التطبيق (Splash) — يتحقق هل في جلسة صالحة
  Future<void> checkAuthStatus() async {
    final accessToken = await _tokenManager.getAccessToken();
    final refreshToken = await _tokenManager.getRefreshToken();

    if (accessToken == null && refreshToken == null) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    // فيه refresh token مخزّن — بس بلاش نطلب PIN تلقائياً بالـ splash
    // (المفروض PinUnlockPage هي يلي بتطلب PIN وتستخدم هالـ refresh token)
    if (refreshToken != null) {
      state = state.copyWith(status: AuthStatus.needsPin);
      return;
    }

    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<bool> login(LoginRequest request) async {
    final result = await _repo.login(request);
    return result.fold(
      (failure) {
        state = state.copyWith(status: AuthStatus.unauthenticated, error: failure.displayMessage);
        return false;
      },
      (user) {
        state = state.copyWith(
          status: user.hasPinSet ? AuthStatus.authenticated : AuthStatus.needsPin,
          user: user,
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> verifyPhone(VerifyOtpRequest request) async {
    final result = await _repo.verifyPhone(request);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.displayMessage);
        return false;
      },
      (user) {
        state = state.copyWith(status: AuthStatus.needsPin, user: user, error: null);
        return true;
      },
    );
  }

  Future<bool> setPin(String pin) async {
    final result = await _repo.setPin(pin);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.displayMessage);
        return false;
      },
      (_) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: state.user?.copyWith(hasPinSet: true),
          error: null,
        );
        return true;
      },
    );
  }

  Future<bool> pinLogin(String pin) async {
    final result = await _repo.pinLogin(pin);
    return result.fold(
      (failure) {
        state = state.copyWith(error: failure.displayMessage);
        return false;
      },
      (user) {
        state = state.copyWith(status: AuthStatus.authenticated, user: user, error: null);
        return true;
      },
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// يُستدعى من الـ interceptor لما الـ refresh يفشل نهائياً
  void forceLogout() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final StateNotifierProvider<AuthStateNotifier, AuthState> authStateNotifierProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(tokenManagerProvider),
  );
});

final Provider<User?> currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateNotifierProvider).user;
});

final Provider<UserType?> userRoleProvider = Provider<UserType?>((ref) {
  return ref.watch(authStateNotifierProvider).role;
});
