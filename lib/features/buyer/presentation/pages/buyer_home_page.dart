import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/buyer_bottom_nav.dart';
import '../widgets/offer_card.dart';

/// الصفحة الرئيسية للمشتري — مطابقة لتصميم "وصلة | سوبرماركت القدس"
class BuyerHomePage extends ConsumerWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(userName: user?.name ?? 'زائر'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WalletChip(),
                    const SizedBox(height: 20),
                    const Text(
                      'عروض الكرتونة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    // بيانات تجريبية — اربطها لاحقاً بـ FutureProvider يقرأ /api/products?featured=true
                    OfferCard(
                      merchantName: 'مطاحن الشرق',
                      productName: 'زيت ذرة نقي (كرتونة 12 لتر)',
                      isFoodBadge: true,
                      price: 135,
                      onAdd: () {},
                    ),
                    const SizedBox(height: 12),
                    OfferCard(
                      merchantName: 'شركة القدس',
                      productName: 'أرز بسمتي 25 كغ',
                      isFoodBadge: false,
                      price: 110,
                      onAdd: () {},
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'الموردون المميزون',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    _MerchantTile(name: 'مطاحن الشرق', category: 'مواد غذائية', rating: 4.8),
                    const SizedBox(height: 10),
                    _MerchantTile(name: 'شركة القدس', category: 'بقالة عامة', rating: 4.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BuyerBottomNav(currentIndex: 0),
    );
  }
}

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.storefront, color: Colors.white, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'وصلة . $userName',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, color: Colors.white70, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ابحث عن منتج أو مورد',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletChip extends StatelessWidget {
  const _WalletChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined, color: AppColors.mint, size: 18),
              SizedBox(width: 6),
              Text('الحد الأقصى: 25,000 ₪', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          Text('الرصيد: 4,850 ₪', style: TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MerchantTile extends StatelessWidget {
  final String name;
  final String category;
  final double rating;

  const _MerchantTile({required this.name, required this.category, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.storefront_outlined, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(category, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.star, color: AppColors.warning, size: 16),
              const SizedBox(width: 4),
              Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
