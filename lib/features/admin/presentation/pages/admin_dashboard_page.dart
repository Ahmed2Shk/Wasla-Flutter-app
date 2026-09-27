import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المسؤول')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: const [
              _StatCard(title: 'إجمالي المستخدمين', value: '1,284', icon: Icons.people_outline, color: AppColors.info),
              _StatCard(title: 'الموزعون', value: '96', icon: Icons.store_outlined, color: AppColors.mint),
              _StatCard(title: 'الطلبات هذا الشهر', value: '3,410', icon: Icons.shopping_bag_outlined, color: AppColors.accent),
              _StatCard(title: 'إجمالي العمولات', value: '3,410 ₪', icon: Icons.savings_outlined, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 20),
          const Text('الإدارة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _ManagementTile(icon: Icons.people_outline, label: 'إدارة المستخدمين', subtitle: 'حظر، حذف، مراجعة الحسابات', onTap: () {}),
          const SizedBox(height: 10),
          _ManagementTile(icon: Icons.receipt_long_outlined, label: 'مراقبة الطلبات', subtitle: 'كل الطلبات على المنصة', onTap: () {}),
          const SizedBox(height: 10),
          _ManagementTile(icon: Icons.bar_chart_outlined, label: 'التقارير المالية', subtitle: 'الإيرادات والعمولات', onTap: () {}),
          const SizedBox(height: 10),
          _ManagementTile(icon: Icons.settings_outlined, label: 'إعدادات النظام', subtitle: 'إعدادات عامة للمنصة', onTap: () {}),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ManagementTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.35), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: AppColors.mint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.chevron_left, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
