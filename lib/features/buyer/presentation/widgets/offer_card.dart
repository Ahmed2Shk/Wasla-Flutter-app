import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class OfferCard extends StatelessWidget {
  final String merchantName;
  final String productName;
  final double price;
  final bool isFoodBadge;
  final VoidCallback onAdd;

  const OfferCard({
    required this.merchantName,
    required this.productName,
    required this.price,
    required this.onAdd,
    this.isFoodBadge = false,
    super.key,
  });

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
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_outlined, color: Colors.white70),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(merchantName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
                    if (isFoodBadge) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مواد غذائية',
                          style: TextStyle(color: AppColors.mint, fontSize: 9.5),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${price.toStringAsFixed(0)} ₪',
                  style: const TextStyle(color: AppColors.mint, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onAdd,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(64, 36),
              padding: EdgeInsets.zero,
              backgroundColor: AppColors.accent,
            ),
            child: const Text('أضف', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
