import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BuyerBottomNav extends StatelessWidget {
  final int currentIndex;
  const BuyerBottomNav({required this.currentIndex, super.key});

  static const _routes = [
    '/home',
    '/buyer/orders',
    '/buyer/merchants',
    '/settings',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == currentIndex) return;
        context.go(_routes[index]);
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'الطلبات'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), label: 'الموردون'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
      ],
    );
  }
}
