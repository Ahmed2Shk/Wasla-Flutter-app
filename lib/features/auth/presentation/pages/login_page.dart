import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/auth_requests.dart';
import '../providers/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final notifier = ref.read(authStateNotifierProvider.notifier);
    final ok = await notifier.login(
      LoginRequest(
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      ),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      final state = ref.read(authStateNotifierProvider);
      if (state.status == AuthStatus.needsPin) {
        context.go('/auth/set-pin');
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(Icons.hub_outlined, color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'أهلاً بك في وصلة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'سجّل الدخول للمتابعة',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              AppTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '05xxxxxxxx',
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                obscureText: _obscure,
                prefixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),

              if (authState.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  authState.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 28),
              AppButton(
                label: 'تسجيل الدخول',
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/auth/forgot-password'),
                child: const Text('نسيت كلمة المرور؟'),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('ليس لديك حساب؟', style: TextStyle(color: AppColors.textSecondary)),
                  TextButton(
                    onPressed: () => context.push('/auth/register'),
                    child: const Text('إنشاء حساب جديد'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
