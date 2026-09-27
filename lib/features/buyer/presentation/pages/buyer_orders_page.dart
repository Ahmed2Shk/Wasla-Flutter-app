import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/buyer_bottom_nav.dart';

class BuyerOrdersPage extends StatelessWidget {
  const BuyerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلباتي'),
          bottom: const TabBar(
            indicatorColor: AppColors.mint,
            tabs: [Tab(text: 'الحالية'), Tab(text: 'السابقة')],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _ActiveOrderTrackingCard(),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                _PastOrderTile(id: '#1030', merchant: 'مستودعات الشمال', itemsCount: 5, total: 2140, status: 'تم التسليم'),
                SizedBox(height: 12),
                _PastOrderTile(id: '#1020', merchant: 'مطاحن الشرق', itemsCount: 2, total: 640, status: 'تم التسليم'),
              ],
            ),
          ],
        ),
        bottomNavigationBar: const BuyerBottomNav(currentIndex: 1),
      ),
    );
  }
}

class _ActiveOrderTrackingCard extends StatelessWidget {
  const _ActiveOrderTrackingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('طلب #1042', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('مطاحن الشرق', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.map_outlined, color: AppColors.textMuted, size: 32),
            ),
          ),
          const SizedBox(height: 14),
          const Text('يصل خلال 25 دقيقة', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const _TrackingStep(label: 'تم قبول الطلب', done: true),
          const _TrackingStep(label: 'تم التجهيز والتحصيل', done: true),
          const _TrackingStep(label: 'في الطريق إليك', done: true, active: true),
          const _TrackingStep(label: 'تم التسليم', done: false),
          const SizedBox(height: 8),
          Row(
            children: [
              const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, color: Colors.white, size: 18)),
              const SizedBox(width: 10),
              const Expanded(child: Text('خالد - الموصّل', style: TextStyle(fontSize: 13))),
              IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined, color: AppColors.mint)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  final String label;
  final bool done;
  final bool active;
  const _TrackingStep({required this.label, required this.done, this.active = false});

  @override
  Widget build(BuildContext context) {
    final color = done ? AppColors.mint : (active ? AppColors.accent : AppColors.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: done || active ? AppColors.textPrimary : AppColors.textMuted, fontSize: 13)),
        ],
      ),
    );
  }
}

class _PastOrderTile extends StatelessWidget {
  final String id;
  final String merchant;
  final int itemsCount;
  final double total;
  final String status;

  const _PastOrderTile({
    required this.id,
    required this.merchant,
    required this.itemsCount,
    required this.total,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$id . $merchant', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text('$itemsCount أصناف', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${total.toStringAsFixed(0)} ₪', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(status, style: const TextStyle(color: AppColors.mint, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
