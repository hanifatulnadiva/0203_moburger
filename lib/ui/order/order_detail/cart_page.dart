import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/bloc/cart/cart_state.dart';
import 'package:moburger/core/widget/widget_cart_item.dart';
import 'package:moburger/ui/order/order_detail/checkout_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Keranjang Belanja', style: AppTextStyles.judul),
        centerTitle: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<OrderBloc, OrderState>(
            listener: (context, state) {
              if (state is OrderCreateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pesanan berhasil dibuat!')),
                );
                context.read<CartBloc>().add(ClearCart());
                Navigator.pop(context);
              }
              if (state is OrderFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal: ${state.errorMessage}')),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is! CartLoaded || state.cartItems.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.shopping_cart_outlined,
                title: 'Keranjangmu Kosong',
                description: 'Yuk, cari burger favoritmu di menu utama!',
              );
            }

            final items = state.cartItems;
            int subtotal = items.fold(0, (sum, item) => sum + ((item['harga'] as int) * (item['qty'] as int)));

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) => CartItemCard(item: items[index]),
                  ),
                ),
                _buildBottomCheckoutPanel(totalPrice: subtotal, items: items),
              ],
            );
          },
        ),
      ),
    );
  }
  Widget _buildBottomCheckoutPanel({required int totalPrice, required List<Map<String, dynamic>> items}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rp ${_formatPrice(totalPrice)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkRed)),
              ],
            ),
            const SizedBox(height: 20),
            BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Pesan Sekarang',
                  backgroundColor: AppColors.orange,
                  isLoading: state is OrderLoading,
                  onPressed: () {
                    final user = Supabase.instance.client.auth.currentUser;
                    final String nama = user?.userMetadata?['nama_lengkap'] ?? 'Pelanggan';

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          totalPrice: totalPrice,
                          items: items,
                          namaCustomer: nama, // Nama otomatis dari profil
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}