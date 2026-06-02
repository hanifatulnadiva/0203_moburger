import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';

class CustomSearchBar extends StatelessWidget {

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Cari...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),

          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius:BorderRadius.circular(16),
            border: Border.all(
              color:AppColors.textSecondary,
            ),
          ),

          child: Row(
            children: [
              const Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: 14,
                  ),

                  onChanged: onChanged,

                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),

                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.zero,
                  ),
                ),
              ),

              if (controller.text.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: const Icon(
                    Icons.close_rounded,
                    color: AppColors.background,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}