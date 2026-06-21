import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
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

  void _navigateToCheckout(BuildContext context, String nama, int total, List<Map<String, dynamic>> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          totalPrice: total,
          items: items,
          namaCustomer: nama,
        ),
      ),
    );
  }
  void _showAdminInputDialog(BuildContext context, int total, List<Map<String, dynamic>> items) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nama Pelanggan"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Masukkan nama customer"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCheckout(context, controller.text.isNotEmpty ? controller.text : "Pelanggan", total, items);
            },
            child: const Text("Lanjut"),
          ),
        ],
      ),
    );
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
                  onPressed: ()async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      _navigateToCheckout(context, "Pelanggan", totalPrice, items);
                      return;
                    }
                    try{
                      final userData = await Supabase.instance.client
                        .from('users')
                        .select('nama_lengkap, role')
                        .eq('id',user.id)
                        .single(); 
                      final String role = userData['role'] ?? 'user';
                      final String namaDariDb = userData['nama_lengkap'] ?? 'Pelanggan';

                      if (role == 'admin') {
                        _showAdminInputDialog(context, totalPrice, items);
                      } else {
                        _navigateToCheckout(context, namaDariDb, totalPrice, items);
                      }
                    } catch (e) {
                      _navigateToCheckout(context, "Pelanggan", totalPrice, items);
                    }
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