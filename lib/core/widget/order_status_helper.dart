import 'package:moburger/core/contants/colors.dart';
import 'package:flutter/material.dart';

/// Helper terpusat untuk alur status pesanan admin.
///
/// Dipakai bersama oleh [AdminOrderCard] dan [OrderDetailPage] agar string
/// status ('diprosess', 'siap diambil', 'selesai') tidak terduplikasi dan
/// berisiko typo di beberapa tempat berbeda.
class OrderStatusHelper {
  OrderStatusHelper._();

  /// Mengembalikan (label tombol, status berikutnya) untuk status saat ini.
  /// Null jika tidak ada aksi lanjutan (misal sudah 'selesai').
  static (String label, String nextStatus)? nextAction(String currentStatus) {
    switch (currentStatus) {
      case 'diprosess':
        return ('Siap Diambil', 'siap diambil');
      case 'siap diambil':
        return ('Selesaikan', 'selesai');
      default:
        return null;
    }
  }

  static Color badgeColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.darkRed;
      case 'diprosess':
        return AppColors.orange;
      case 'siap diambil':
        return AppColors.info;
      case 'selesai':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }
}