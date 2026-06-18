import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/data/models/order_model.dart';

class AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const AdminOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final actionData = _getNextAction(order.status);
    final nextAction = actionData?.$1;
    final nextStatus = actionData?.$2;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: ID Order dan Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order #${order.order_number}', style: AppTextStyles.formLabel),
                Text(
                  _getFormattedStatus(order.status),
                  style: TextStyle(
                    color: _statusTextColor(order.status),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Update Terakhir: ${_formatDate(order.updateAt)}',
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 4),
            const Divider(),
            
            // Informasi Customer & Total
            Text('Pelanggan: ${order.nama_customer ?? 'Umum'}', style: AppTextStyles.bodyRegular),
            // --- DETAIL ITEM & TOPPING (ExpansionTile) ---
            if (order.items != null && order.items!.isNotEmpty)
            ExpansionTile(
              title: const Text("Lihat Detail Pesanan", 
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              tilePadding: EdgeInsets.zero,
              children: order.items!.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${item.quantity}x ${item.menuName}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          if (item.toppingNames.isNotEmpty)
                            Text("Topping: ${item.toppingNames.join(', ')}",
                                style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                        ],
                      ),
                      Text("Rp ${item.subTotal.toInt()}", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                );
              }).toList(),
            ),

          // 2. Total harga diletakkan di luar ExpansionTile (Hanya muncul sekali)
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkRed)),
                Text("Rp ${order.total_price}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

            // Catatan (Opsional)
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Catatan: ${order.notes}',
                  style: AppTextStyles.bodyRegular.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
                  maxLines: 2, overflow: TextOverflow.ellipsis),
            ],

            // Tombol Aksi
            if (nextAction != null) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                text: nextAction,
                onPressed: () => context.read<OrderBloc>().add(
                    UpdateOrderStatusEvent(orderId: order.id, status: nextStatus!)),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---
  (String, String)? _getNextAction(String status) {
    final s = status.toLowerCase();
    if (s == 'diprosess') return ('Siap Diambil', 'siap diambil');
    if (s == 'siap diambil') return ('Selesaikan', 'selesai');
    return null;
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'diprosess': return AppColors.orange;
      case 'siap diambil': return Colors.amber[800]!;
      case 'selesai': return AppColors.success;
      default: return Colors.grey;
    }
  }

  String _getFormattedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'diprosess': return "Dalam Proses";
      case 'siap diambil': return "Siap Diambil";
      case 'selesai': return "Selesai";
      default: return status.toUpperCase();
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime dateTime = DateTime.parse(dateString);
      return DateFormat('dd MMM, HH:mm').format(dateTime);
    } catch (e) {
      return dateString; // Tampilkan mentah jika format salah
    }
  }
}