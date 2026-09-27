import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../buyer/presentation/widgets/buyer_bottom_nav.dart';

class AccountSettingsPage extends ConsumerWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final role = ref.watch(userRoleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 10),
                Text(user?.name ?? '---', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(user?.phoneNumber ?? '---', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _Section(title: 'الملف الشخصي', children: [
            _Tile(icon: Icons.person_outline, title: 'تعديل البيانات', subtitle: user?.name ?? '', onTap: () {}),
            _Tile(icon: Icons.email_outlined, title: 'البريد الإلكتروني', subtitle: user?.email ?? 'غير محدد', onTap: () {}),
            _Tile(icon: Icons.location_on_outlined, title: 'العنوان', subtitle: '${user?.city ?? ''} - ${user?.area ?? ''}', onTap: () {}),
          ]),

          _Section(title: 'الأمان', children: [
            _Tile(icon: Icons.lock_outline, title: 'تغيير كلمة المرور', onTap: () {}),
            _Tile(icon: Icons.pin_outlined, title: 'تغيير رمز الـ PIN', onTap: () {}),
          ]),

          if (role?.arabicLabel != null)
            _Section(title: 'نوع الحساب', children: [
              _Tile(icon: Icons.badge_outlined, title: role!.arabicLabel, onTap: null),
            ]),

          _Section(title: 'أخرى', children: [
            _Tile(
              icon: Icons.logout,
              title: 'تسجيل الخروج',
              destructive: true,
              onTap: () => _confirmLogout(context, ref),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: const BuyerBottomNav(currentIndex: 3),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ref.read(authStateNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/auth/login');
            },
            child: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(title, style: const TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool destructive;
  final VoidCallback? onTap;

  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.destructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: destructive ? AppColors.error : AppColors.mint),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13.5)),
      subtitle: subtitle != null && subtitle!.isNotEmpty
          ? Text(subtitle!, style: const TextStyle(fontSize: 11.5))
          : null,
      trailing: onTap != null ? const Icon(Icons.chevron_left, color: AppColors.textMuted) : null,
      onTap: onTap,
    );
  }
}
