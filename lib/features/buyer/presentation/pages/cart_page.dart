import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int _paymentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('السلة . 3 أصناف')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _MerchantGroup(
            merchantName: 'مطاحن الشرق',
            items: const [
              _CartLine(name: 'زيت ذرة نقي 12 لتر', qty: 2, price: 270),
              _CartLine(name: 'سائل جلي 5 لتر', qty: 1, price: 58),
            ],
          ),
          const SizedBox(height: 14),
          _MerchantGroup(
            merchantName: 'شركة القدس',
            items: const [
              _CartLine(name: 'أرز بسمتي 25 كغ', qty: 12, price: 1320),
            ],
          ),
          const SizedBox(height: 20),
          const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _PaymentOption(
            label: 'جوال باي',
            icon: Icons.phone_android,
            selected: _paymentIndex == 0,
            onTap: () => setState(() => _paymentIndex = 0),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: 'الدفع عند الاستلام',
            icon: Icons.payments_outlined,
            selected: _paymentIndex == 1,
            onTap: () => setState(() => _paymentIndex = 1),
          ),
          const SizedBox(height: 8),
          _PaymentOption(
            label: 'آجل (من الائتمان)',
            icon: Icons.account_balance_wallet_outlined,
            selected: _paymentIndex == 2,
            onTap: () => setState(() => _paymentIndex = 2),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('الإجمالي', style: TextStyle(color: AppColors.textSecondary)),
                  Text('1,648 ₪', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(label: 'تأكيد الطلب', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartLine {
  final String name;
  final int qty;
  final double price;
  const _CartLine({required this.name, required this.qty, required this.price});
}

class _MerchantGroup extends StatelessWidget {
  final String merchantName;
  final List<_CartLine> items;
  const _MerchantGroup({required this.merchantName, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(merchantName, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(height: 20),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('${item.qty} ×', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item.name, style: const TextStyle(fontSize: 13))),
                  Text('${item.price.toStringAsFixed(0)} ₪', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.mint : Colors.transparent, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.mint : AppColors.textSecondary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(label)),
            if (selected) const Icon(Icons.check_circle, color: AppColors.mint, size: 18),
          ],
        ),
      ),
    );
  }
}
