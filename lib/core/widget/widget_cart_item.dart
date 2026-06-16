import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart'; // Sesuaikan path ini

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Function(String)? onIncrement;
  final Function(String)? onDecrement;

  const CartItemCard({
    super.key,
    required this.item,
    this.onIncrement,
    this.onDecrement,
  });

  String _formatPrice(dynamic price) {
    return price.toString(); 
  }

  @override
  Widget build(BuildContext context) {
    final String cartItemId = item['order_item_id'].toString();
    final String nama = item['nama_menu']?.toString() ?? 'Menu Tanpa Nama';
    final String notes = item['notes']?.toString() ?? '';

    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lunch_dining, color: AppColors.orange, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: AppTextStyles.judul.copyWith(fontSize: 15)),
                if (notes.isNotEmpty)
                  Text('Catatan: $notes', style: AppTextStyles.bodyRegular.copyWith(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('Rp ${_formatPrice(item['harga'])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.orange, size: 22),
                onPressed: onDecrement != null 
                    ? () => onDecrement!(cartItemId) 
                    : () => context.read<CartBloc>().add(DecrementCartItem(cartItemId)),
              ),
              Text('${item['qty']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.orange, size: 22),
                onPressed: onIncrement != null 
                    ? () => onIncrement!(cartItemId) 
                    : () => context.read<CartBloc>().add(IncrementCartItem(cartItemId)),
              ),
            ],
          )
        ],
      ),
    );
  }
}