import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/otp_input_field.dart';
import '../../data/models/auth_requests.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _phoneController = TextEditingController();
  final _newPasswordController = TextEditingController();

  int _step = 0; // 0 = enter phone, 1 = enter code + new password
  String _code = '';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.sendOtp(
      SendOtpRequest(phoneNumber: _phoneController.text.trim(), purpose: OtpPurpose.forgotPassword),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => setState(() => _error = failure.message),
      (_) => setState(() => _step = 1),
    );
  }

  Future<void> _handleReset() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.resetPassword(
      ResetPasswordRequest(
        phoneNumber: _phoneController.text.trim(),
        code: _code,
        newPassword: _newPasswordController.text,
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => setState(() => _error = failure.message),
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تغيير كلمة المرور، سجّل الدخول من جديد')),
        );
        context.go('/auth/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('استرجاع كلمة المرور')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _step == 0 ? _buildPhoneStep() : _buildResetStep(),
        ),
      ),
    );
  }

  Widget _buildPhoneStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_reset_outlined, size: 56, color: AppColors.mint),
        const SizedBox(height: 16),
        const Text(
          'أدخل رقم هاتفك المسجّل وبنبعتلك رمز تحقق',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        AppTextField(
          controller: _phoneController,
          label: 'رقم الهاتف',
          hint: '05xxxxxxxx',
          keyboardType: TextInputType.phone,
        ),
        if (_error != null) ...[
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 24),
        AppButton(label: 'إرسال الرمز', isLoading: _isLoading, onPressed: _handleSendCode),
      ],
    );
  }

  Widget _buildResetStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أدخل الرمز المرسل إلى ${_phoneController.text}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SegmentedCodeInput(length: 6, onCompleted: (c) => setState(() => _code = c)),
          const SizedBox(height: 20),
          AppTextField(
            controller: _newPasswordController,
            label: 'كلمة المرور الجديدة',
            obscureText: true,
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          AppButton(
            label: 'تغيير كلمة المرور',
            isLoading: _isLoading,
            onPressed: _code.length == 6 ? _handleReset : null,
          ),
        ],
      ),
    );
  }
}
