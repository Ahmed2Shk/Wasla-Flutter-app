import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../../data/models/auth_requests.dart';
import '../providers/auth_providers.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final OtpPurpose purpose;

  const VerifyOtpPage({
    required this.phoneNumber,
    this.purpose = OtpPurpose.registration,
    super.key,
  });

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  String _code = '';
  bool _isLoading = false;
  String? _error;
  int _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  Future<void> _handleVerify() async {
    if (_code.length != 6) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final notifier = ref.read(authStateNotifierProvider.notifier);
    final ok = await notifier.verifyPhone(
      VerifyOtpRequest(phoneNumber: widget.phoneNumber, code: _code, purpose: widget.purpose),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      context.go('/auth/set-pin');
    } else {
      setState(() => _error = ref.read(authStateNotifierProvider).error);
    }
  }

  Future<void> _handleResend() async {
    _startCountdown();
    final repo = ref.read(authRepositoryProvider);
    await repo.sendOtp(SendOtpRequest(phoneNumber: widget.phoneNumber, purpose: widget.purpose));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال رمز جديد')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التحقق من رقم الهاتف')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'تم إرسال رمز مكوّن من 6 أرقام إلى ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              SegmentedCodeInput(
                length: 6,
                onCompleted: (code) => setState(() => _code = code),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
              ],
              const SizedBox(height: 32),
              AppButton(
                label: 'تحقق',
                isLoading: _isLoading,
                onPressed: _code.length == 6 ? _handleVerify : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _secondsLeft > 0 ? null : _handleResend,
                  child: Text(
                    _secondsLeft > 0 ? 'إعادة الإرسال خلال $_secondsLeft ثانية' : 'إعادة إرسال الرمز',
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
