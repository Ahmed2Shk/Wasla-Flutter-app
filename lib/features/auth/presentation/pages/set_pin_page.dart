import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../providers/auth_providers.dart';

class SetPinPage extends ConsumerStatefulWidget {
  const SetPinPage({super.key});

  @override
  ConsumerState<SetPinPage> createState() => _SetPinPageState();
}

class _SetPinPageState extends ConsumerState<SetPinPage> {
  String? _firstPin;
  bool _isConfirmStep = false;
  bool _isLoading = false;
  String? _error;
  int _resetKey = 0;

  Future<void> _onCodeEntered(String code) async {
    if (!_isConfirmStep) {
      setState(() {
        _firstPin = code;
        _isConfirmStep = true;
        _resetKey++;
      });
      return;
    }

    if (code != _firstPin) {
      setState(() {
        _error = 'الرمزان غير متطابقين، حاول مجدداً';
        _isConfirmStep = false;
        _firstPin = null;
        _resetKey++;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final ok = await ref.read(authStateNotifierProvider.notifier).setPin(code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      context.go('/home');
    } else {
      setState(() {
        _error = ref.read(authStateNotifierProvider).error;
        _isConfirmStep = false;
        _firstPin = null;
        _resetKey++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تعيين رمز PIN')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                _isConfirmStep ? Icons.lock_reset_outlined : Icons.pin_outlined,
                size: 56,
                color: AppColors.mint,
              ),
              const SizedBox(height: 16),
              Text(
                _isConfirmStep ? 'أكّد رمز الـ PIN' : 'عيّن رمز PIN من 4 أرقام',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'هذا الرمز رح يستخدم للدخول السريع بدل كلمة المرور',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('تخطّي الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
