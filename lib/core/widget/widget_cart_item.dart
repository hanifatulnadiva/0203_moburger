import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';

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

  Widget _menuPlaceholderIcon() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.darkRed.withOpacity(0.08),
      child: const Icon(Icons.lunch_dining, color: AppColors.darkRed, size: 28),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final String cartItemId = item['order_item_id']?.toString() ?? '';
    final String nama = item['nama_menu']?.toString() ?? 'Menu Tanpa Nama';
    final String notes = item['notes']?.toString() ?? '';
    final String? imageUrl = item['image_url']?.toString();

    return CustomCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    // Tambahkan errorBuilder untuk menangani HandshakeException/koneksi
                    errorBuilder: (context, error, stackTrace) => _menuPlaceholderIcon(),
                  )
                : _menuPlaceholderIcon(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nama, style: AppTextStyles.judul.copyWith(fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                if (notes.isNotEmpty)
                  Text('Catatan: $notes', style: AppTextStyles.bodyRegular.copyWith(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('Rp ${_formatPrice(item['harga'])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, color: AppColors.orange, size: 22),
                onPressed: () {
                  if (onDecrement != null) {
                    onDecrement!(cartItemId);
                  } else {
                    context.read<CartBloc>().add(DecrementCartItem(cartItemId));
                  }
                },
              ),
              Text('${item['qty'] ?? 0}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: AppColors.orange, size: 22),
                onPressed: () {
                  if (onIncrement != null) {
                    onIncrement!(cartItemId);
                  } else {
                    context.read<CartBloc>().add(IncrementCartItem(cartItemId));
                  }
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}