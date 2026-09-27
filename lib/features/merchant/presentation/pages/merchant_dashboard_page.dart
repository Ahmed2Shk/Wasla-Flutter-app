import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class MerchantDashboardPage extends ConsumerWidget {
  const MerchantDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.name ?? 'لوحة التاجر'),
        actions: [
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // رصيد المحفظة — تنبيه استمرارية الظهور (balance continuity rule)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('رصيد المحفظة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                const Text('342 ₪', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'يُخصم 1 ₪ عمولة عند قبول كل طلب — حافظ على رصيد كافٍ ليبقى متجرك ظاهراً للمشترين',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: const Text('شحن الرصيد (جوال باي)'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _StatCard(label: 'طلبات قيد الانتظار', value: '3', icon: Icons.pending_actions_outlined, color: AppColors.warning)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(label: 'مبيعات اليوم', value: '1,240 ₪', icon: Icons.trending_up, color: AppColors.mint)),
            ],
          ),

          const SizedBox(height: 20),
          const Text('طلبات جديدة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          _OrderRequestTile(
            orderId: '#1043',
            buyerName: 'محل أبو خالد',
            itemsCount: 4,
            total: 410,
          ),
          const SizedBox(height: 10),
          _OrderRequestTile(
            orderId: '#1044',
            buyerName: 'سوبرماركت الأمل',
            itemsCount: 2,
            total: 175,
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.inventory_2_outlined,
                  label: 'منتجاتي',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.receipt_long_outlined,
                  label: 'كل الطلبات',
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.star_outline,
                  label: 'تقييمات المشترين',
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _OrderRequestTile extends StatelessWidget {
  final String orderId;
  final String buyerName;
  final int itemsCount;
  final double total;

  const _OrderRequestTile({
    required this.orderId,
    required this.buyerName,
    required this.itemsCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$orderId . $buyerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('${total.toStringAsFixed(0)} ₪', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text('$itemsCount أصناف', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                  child: const Text('رفض'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('قبول'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: AppColors.mint),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
