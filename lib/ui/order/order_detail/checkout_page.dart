import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/cart/cart_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/widget_cart_item.dart'; // Pastikan path benar
import 'package:moburger/ui/order/order_detail/midtrans_webview_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:moburger/bloc/cart/cart_event.dart';

class CheckoutScreen extends StatefulWidget {
  final int totalPrice;
  final List<Map<String, dynamic>> items;
  final String namaCustomer;

  const CheckoutScreen({
    super.key,
    required this.totalPrice,
    required this.items,
    required this.namaCustomer,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _fetchTokenAndStartPayment(List<Map<String, dynamic>> currentItems, int currentTotal) async {
    setState(() => _isLoading = true);
    try {
      final payloadItems = currentItems.map((item) => {
            'menu_id': item['menu_id'] ?? item['id'],
            'qty': item['qty'],
            'harga': item['harga'],
            'nama': item['nama_menu'],
            'catatan': item['notes'] ?? '',
            'subtotal': (item['harga'] as int) * (item['qty'] as int),
            'toppings': item['toppings'] ?? [],
          }).toList();

      final response = await Supabase.instance.client.functions.invoke(
        'create_payment',
        body: {
          'total_price': currentTotal,
          'nama_customer': widget.namaCustomer,
          'items': payloadItems,
          'payment_type': 'all',
          'notes': currentItems
            .map((e) => e['notes'] ?? '')
            .where((e) => e.toString().isNotEmpty)
            .join('\n'),
        },
      );

      // 1. Tambahkan Debugging untuk melihat isi respon
      print("DEBUG RES: ${response.data}");

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Gagal membuat transaksi');
      }

      final String? redirectUrl = response.data['redirect_url'];
      final String? orderNumber = response.data['order_number'];

      if (redirectUrl == null || !redirectUrl.startsWith('http')) {
        throw Exception('URL Pembayaran tidak valid dari server!');
      }

      if (mounted) {
        context.read<CartBloc>().add(ClearCart());
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MidtransWebViewPage(
              paymentUrl: redirectUrl, 
              orderNumber: orderNumber ?? 'UNKNOWN',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, title: const Text("Checkout")),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          final items = (state is CartLoaded) ? state.cartItems : widget.items;
          final total = items.fold(0, (sum, item) => sum + ((item['harga'] as int) * (item['qty'] as int)));

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildProfileCard(),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Pesanan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 12),
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: CartItemCard(item: item),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              _buildBottomPanel(total, items),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
    child: Row(
      children: [
        const Icon(Icons.person, color: AppColors.orange),
        const SizedBox(width: 10),
        Text(widget.namaCustomer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    ),
  );

  Widget _buildBottomPanel(int total, List<Map<String, dynamic>> items) => Container(
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
                  Text('Rp ${_formatPrice(total)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkRed)),
                ],
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: "Bayar Sekarang",
                backgroundColor: AppColors.orange,
                isLoading: _isLoading,
                onPressed: () => _fetchTokenAndStartPayment(items, total),
              ),
            ],
          ),
        ),
      );
}