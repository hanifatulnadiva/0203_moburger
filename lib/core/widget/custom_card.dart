import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart'; // Sesuaikan typo 'contants' dari path-mu jika perlu

class CustomCard extends StatelessWidget {
  final Widget child;                  // Isi utama di dalam card (Bebas: Teks, Row, Column, Image)
  final VoidCallback? onTap;           // Aksi ketika card di-klik
  final String? badgeText;             // Teks label/status opsional (misal: 'Promo', 'Diproses')
  final Color? badgeColor;             // Warna background badge opsional
  final Color? badgeTextColor;         // Warna teks badge opsional
  final double borderRadius;           // Lekukan sudut card
  final EdgeInsetsGeometry padding;    // Jarak dalam card
  final Color backgroundColor;         // Warna background card

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.badgeText,
    this.badgeColor,
    this.badgeTextColor,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16.0),
    this.backgroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: backgroundColor,
      elevation: 1.5,
      shadowColor: AppColors.textSecondary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          color: AppColors.textSecondary.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Stack(
          children: [
            // Konten Utama dari Card
            Padding(
              padding: padding,
              child: child,
            ),
            
            // Badge/Label di pojok kanan atas jika data badgeText dikirim
            if (badgeText != null)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.orange,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                  ),
                  child: Text(
                    badgeText!,
                    style: TextStyle(
                      color: badgeTextColor ?? AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}