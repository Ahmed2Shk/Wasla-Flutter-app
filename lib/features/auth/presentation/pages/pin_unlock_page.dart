import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../providers/auth_providers.dart';

class PinUnlockPage extends ConsumerStatefulWidget {
  const PinUnlockPage({super.key});

  @override
  ConsumerState<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends ConsumerState<PinUnlockPage> {
  bool _isLoading = false;
  String? _error;
  int _resetKey = 0;

  Future<void> _onCodeEntered(String pin) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final ok = await ref.read(authStateNotifierProvider.notifier).pinLogin(pin);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      context.go('/home');
    } else {
      setState(() {
        _error = ref.read(authStateNotifierProvider).error ?? 'رمز غير صحيح';
        _resetKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.white, size: 42),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'أدخل رمز الـ PIN',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: AppColors.mint))
              else
                SegmentedCodeInput(
                  key: ValueKey(_resetKey),
                  length: 4,
                  obscure: true,
                  onCompleted: _onCodeEntered,
                ),
              if (_error != null) ...[
                const SizedBox(height: 20),
                Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref.read(authStateNotifierProvider.notifier).logout();
                    if (context.mounted) context.go('/auth/login');
                  },
                  child: const Text(
                    'الدخول برقم آخر (تسجيل خروج)',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
