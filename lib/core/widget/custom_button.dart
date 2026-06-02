import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart'; 

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false, 
    this.backgroundColor = AppColors.orange, 
    this.textColor = AppColors.white, 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, 
      height: 52, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0, 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), 
          ),
        ),
        onPressed: isLoading ? null : onPressed, 
        child: isLoading? 
          const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              color: AppColors.white,
              strokeWidth: 3,
            ),
          )
        : Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
      ),
    );
  }
}