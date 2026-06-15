import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';

/// Widget quantity selector reusable (+/-).
/// Bisa dipakai di halaman detail menu, keranjang, atau halaman lainnya.
///
/// Contoh penggunaan:
/// ```dart
/// CustomQuantitySelector(
///   quantity: _quantity,
///   onIncrement: _increment,
///   onDecrement: _decrement,
/// )
/// ```
class CustomQuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  /// Tinggi container tombol (default 50)
  final double height;

  /// Lebar tiap tombol + dan - (default 44)
  final double buttonWidth;

  /// Lebar area angka quantity (default 32)
  final double numberWidth;

  const CustomQuantitySelector({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.height = 50,
    this.buttonWidth = 44,
    this.numberWidth = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: const Color(0xFFD5C3B8), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyButton(
            icon: Icons.remove,
            onTap: onDecrement,
            buttonWidth: buttonWidth,
            height: height,
          ),
          SizedBox(
            width: numberWidth,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          _QtyButton(
            icon: Icons.add,
            onTap: onIncrement,
            buttonWidth: buttonWidth,
            height: height,
          ),
        ],
      ),
    );
  }
}

// Tombol internal +/-
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double buttonWidth;
  final double height;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.buttonWidth,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        width: buttonWidth,
        height: height,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
