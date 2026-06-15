import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';

class AppTextStyles {
  static const TextStyle formLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Kamu bisa sekalian daftarin style lain di sini nanti:
  static const TextStyle headingBold = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  static const TextStyle bodyOrange = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.orange,
  );
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
  static const TextStyle judul=TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18);
}