import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/enums.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../data/models/auth_requests.dart';
import '../providers/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  UserType _selectedType = UserType.buyer;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  final _streetController = TextEditingController();
  final _landmarkController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _streetController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(
      RegisterRequest(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
        userType: _selectedType,
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
        street: _streetController.text.trim(),
        landmark: _landmarkController.text.trim().isEmpty ? null : _landmarkController.text.trim(),
      ),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.fold(
      (failure) => setState(() => _error = failure.displayMessage),
      (_) => context.push('/auth/verify-otp', extra: {
        'phoneNumber': _phoneController.text.trim(),
        'purpose': OtpPurpose.registration,
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'اختر نوع حسابك',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _AccountTypeCard(
                title: 'مشتري',
                subtitle: 'تصفّح الموزعين واطلب بضائعك بسهولة',
                icon: Icons.storefront_outlined,
                selected: _selectedType == UserType.buyer,
                onTap: () => setState(() => _selectedType = UserType.buyer),
              ),
              const SizedBox(height: 12),
              _AccountTypeCard(
                title: 'تاجر / مورد',
                subtitle: 'أضف منتجاتك واستقبل طلبات المحلات',
                icon: Icons.warehouse_outlined,
                selected: _selectedType == UserType.merchant,
                onTap: () => setState(() => _selectedType = UserType.merchant),
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 8),

              AppTextField(controller: _nameController, label: 'الاسم / اسم النشاط'),
              const SizedBox(height: 14),
              AppTextField(
                controller: _emailController,
                label: 'البريد الإلكتروني (اختياري)',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _phoneController,
                label: 'رقم الهاتف',
                hint: '05xxxxxxxx',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: _passwordController,
                label: 'كلمة المرور',
                obscureText: true,
              ),

              const SizedBox(height: 20),
              const Text('العنوان', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              AppTextField(controller: _cityController, label: 'المدينة'),
              const SizedBox(height: 14),
              AppTextField(controller: _areaController, label: 'المنطقة'),
              const SizedBox(height: 14),
              AppTextField(controller: _streetController, label: 'الشارع'),
              const SizedBox(height: 14),
              AppTextField(controller: _landmarkController, label: 'معلم مهم (اختياري)'),

              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(_error!, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
              ],

              const SizedBox(height: 24),
              AppButton(
                label: 'إنشاء الحساب',
                isLoading: _isLoading,
                onPressed: _handleRegister,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.mint : AppColors.divider,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<bool>(
              value: true,
              groupValue: selected ? true : null,
              onChanged: (_) => onTap(),
              activeColor: AppColors.mint,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.mint),
            ),
          ],
        ),
      ),
    );
  }
}
