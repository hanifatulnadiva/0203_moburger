import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';

class CustomAlertDialog {
  static Future<bool?> showDeleteDialog({
    required BuildContext context,
    required String title,
    required String content,
    bool isDelete = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(title, style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
        content: Text(content, style: TextStyle(color: AppColors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true), 
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(isDelete?"Hapus": "Keluar"),
          ),
        ],
      ),
    );
  }
}