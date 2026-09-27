import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/buyer_bottom_nav.dart';

class MerchantDirectoryPage extends StatelessWidget {
  const MerchantDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final merchants = const [
      ('مطاحن الشرق', 'مواد غذائية', 4.8, true),
      ('شركة القدس', 'بقالة عامة', 4.6, true),
      ('مستودعات الشمال', 'منظفات', 4.3, true),
      ('الأمين للتجارة', 'مواد غذائية', 3.9, false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('الموردون')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: merchants.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final (name, category, rating, isOnline) = merchants[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.storefront_outlined, color: Colors.white),
                    ),
                    if (isOnline)
                      Positioned(
                        left: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                        ),
                      ),
                  ],
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
        },
      ),
      bottomNavigationBar: const BuyerBottomNav(currentIndex: 2),
    );
  }
}
