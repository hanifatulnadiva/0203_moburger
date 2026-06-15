import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart'; 

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; 
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon; 
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false, 
    this.backgroundColor = AppColors.textPrimary, 
    this.textColor = AppColors.white, 
    this.icon,
    this.borderRadius = 12, 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      height: 50, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          disabledBackgroundColor: Colors.grey[300], 
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius), 
          ),
        ),
        // Jika sedang loading atau onPressed bernilai null, tombol otomatis ke-lock (disabled)
        onPressed: isLoading ? null : onPressed, 
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 3,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: textColor, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}