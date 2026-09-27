import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_otp_page.dart';
import '../../features/auth/presentation/pages/set_pin_page.dart';
import '../../features/auth/presentation/pages/pin_unlock_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';

import '../../features/buyer/presentation/pages/buyer_home_page.dart';
import '../../features/buyer/presentation/pages/buyer_orders_page.dart';
import '../../features/buyer/presentation/pages/merchant_directory_page.dart';
import '../../features/buyer/presentation/pages/cart_page.dart';

import '../../features/merchant/presentation/pages/merchant_dashboard_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/account/presentation/pages/account_settings_page.dart';

/// يحوّل AuthStateNotifier (StateNotifier) لـ Listenable حتى go_router
/// يقدر يعيد بناء الـ redirect لما تتغير حالة الجلسة
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(this._ref) {
    _ref.listen<AuthState>(authStateNotifierProvider, (previous, next) {
      if (previous?.status != next.status) notifyListeners();
    });
  }
  final Ref _ref;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: listenable,
    redirect: (context, state) {
      final authState = ref.read(authStateNotifierProvider);
      final status = authState.status;
      final loc = state.matchedLocation;

      final isSplash = loc == '/splash';
      final isAuthRoute = loc.startsWith('/auth');

      // أثناء الفحص الأولي، خليه بالـ Splash
      if (status == AuthStatus.unknown) {
        return isSplash ? null : '/splash';
      }

      // خرج من الـ Splash بعد ما عرفنا الحالة
      if (isSplash) {
        switch (status) {
          case AuthStatus.authenticated:
            return '/home';
          case AuthStatus.needsPin:
            return authState.user == null ? '/auth/pin-unlock' : '/auth/set-pin';
          case AuthStatus.unauthenticated:
          default:
            return '/auth/login';
        }
      }

      if (status == AuthStatus.unauthenticated && !isAuthRoute) {
        return '/auth/login';
      }

      if (status == AuthStatus.authenticated && isAuthRoute) {
        return '/home';
      }

      // حماية حسب الدور — مطابقة لسياسات MerchantOnly/BuyerOnly بالسيرفر (تجميلية بالتطبيق فقط)
      final role = authState.role;
      if (status == AuthStatus.authenticated) {
        if (loc.startsWith('/merchant') && role != UserType.merchant) {
          return '/unauthorized';
        }
        if (loc.startsWith('/admin') && role != UserType.admin) {
          return '/unauthorized';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),

      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/auth/verify-otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return VerifyOtpPage(
            phoneNumber: extra?['phoneNumber'] as String? ?? '',
            purpose: extra?['purpose'] as OtpPurpose? ?? OtpPurpose.registration,
          );
        },
      ),
      GoRoute(
        path: '/auth/set-pin',
        builder: (context, state) => const SetPinPage(),
      ),
      GoRoute(
        path: '/auth/pin-unlock',
        builder: (context, state) => const PinUnlockPage(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // الشاشة الرئيسية — تُبنى حسب دور المستخدم
      GoRoute(
        path: '/home',
        builder: (context, state) => const _HomeByRole(),
      ),

      // Buyer
      GoRoute(path: '/buyer/orders', builder: (context, state) => const BuyerOrdersPage()),
      GoRoute(path: '/buyer/merchants', builder: (context, state) => const MerchantDirectoryPage()),
      GoRoute(path: '/buyer/cart', builder: (context, state) => const CartPage()),

      // Merchant
      GoRoute(path: '/merchant', builder: (context, state) => const MerchantDashboardPage()),

      // Admin
      GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardPage()),

      // مشترك لكل الأدوار
      GoRoute(path: '/settings', builder: (context, state) => const AccountSettingsPage()),

      GoRoute(
        path: '/unauthorized',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('ليس لديك صلاحية الوصول لهذه الصفحة')),
        ),
      ),
    ],
  );
});

/// يوجّه المستخدم لواجهته الصحيحة حسب UserType بعد الدخول
class _HomeByRole extends ConsumerWidget {
  const _HomeByRole();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);

    switch (role) {
      case UserType.merchant:
        return const MerchantDashboardPage();
      case UserType.admin:
        return const AdminDashboardPage();
      case UserType.buyer:
      default:
        return const BuyerHomePage();
    }
  }
}
