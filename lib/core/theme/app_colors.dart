import 'package:flutter/material.dart';

/// الألوان مأخوذة من تصاميم وصلة (خلفية داكنة + أخضر مطفي + برتقالي للأكشن)
class AppColors {
  AppColors._();

  // الخلفية
  static const Color background = Color(0xFF101614);
  static const Color surface = Color(0xFF1B2622);
  static const Color surfaceLight = Color(0xFF243330);

  // الأخضر (الهوية البصرية الأساسية)
  static const Color primary = Color(0xFF0F5C46);
  static const Color primaryDark = Color(0xFF0A3D2E);
  static const Color primaryLight = Color(0xFF2F5F53);
  static const Color mint = Color(0xFF4CAF7D);

  // البرتقالي (أزرار "أضف" و CTA الرئيسية)
  static const Color accent = Color(0xFFC97C33);
  static const Color accentDark = Color(0xFFA5652A);

  // النصوص
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFA9B3AF);
  static const Color textMuted = Color(0xFF6E7A76);

  // الحالات
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE55B4D);
  static const Color info = Color(0xFF3B82F6);

  // خطوط وفواصل
  static const Color divider = Color(0xFF2A3733);
}
