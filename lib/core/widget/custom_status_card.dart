import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';

class OptionCard extends StatelessWidget {
  final String label;
  final String? value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.value,
    this.onTap,
  });

  bool get isStatusCard => value != null;

  @override
  Widget build(BuildContext context) {
    return isStatusCard ? _buildStatusCard() : _buildMenuCard();
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.white, size: 18),
          const SizedBox(height: 6),
          Text(value!, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, textAlign: TextAlign.center, style: TextStyle(color: AppColors.white.withOpacity(0.85), fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMenuCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center, style: AppTextStyles.formLabel.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}