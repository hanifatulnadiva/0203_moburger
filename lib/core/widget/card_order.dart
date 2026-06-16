import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:moburger/core/widget/custom_card.dart';

class AdminOrderCard extends StatelessWidget {
  final OrderModel order;

  const AdminOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    String? nextAction;
    String? nextStatus;
    
    // Logika status
    if (order.status == 'diprosess') { 
      nextAction = 'Siap Diambil'; 
      nextStatus = 'siap diambil'; 
    } else if (order.status == 'siap diambil') { 
      nextAction = 'Selesaikan'; 
      nextStatus = 'selesai'; 
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SizedBox(
        // Memaksa kartu mengambil seluruh lebar layar
        width: double.infinity, 
        child: CustomCard(
          badgeText: order.status.toUpperCase(),
          badgeColor: _statusBadgeColor(order.status),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order #${order.order_number ?? order.id.substring(0, 8).toUpperCase()}', 
                style: AppTextStyles.formLabel,
                overflow: TextOverflow.ellipsis, // Mencegah overflow
              ),
              const SizedBox(height: 8),
              Text(
                'Pelanggan: ${order.nama_customer ?? 'Umum'}', 
                style: AppTextStyles.bodyRegular,
                overflow: TextOverflow.ellipsis, // Mencegah overflow
              ),
              Text(
                'Total: Rp ${order.total_price}', 
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkRed)
              ),
            
              // Catatan
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Catatan: ${order.notes}', 
                  style: AppTextStyles.bodyRegular.copyWith(fontStyle: FontStyle.italic, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],

              if (nextAction != null) ...[
                const SizedBox(height: 12),
                PrimaryButton(
                  text: nextAction,
                  onPressed: () => context.read<OrderBloc>().add(UpdateOrderStatusEvent(orderId: order.id, status: nextStatus!)),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Color _statusBadgeColor(String status) {
    switch (status) {
      case 'pending': return AppColors.darkRed;
      case 'diprosess': return AppColors.orange;
      case 'siap diambil': return AppColors.info;
      case 'selesai': return AppColors.success;
      default: return Colors.grey;
    }
  }
}