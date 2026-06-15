import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/ui/order/order_detail/midtrans_webview_page.dart';
import 'package:moburger/ui/order/order_detail/sukses_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String _selectedPayment = 'all';
  bool _isLoading = false;

  final List<Map<String, String>> _paymentOptions = [
    {'id': 'all', 'name': 'Semua Metode'},
    {'id': 'gopay', 'name': 'GoPay'},
    {'id': 'shopeepay', 'name': 'ShopeePay'},
    {'id': 'bank_transfer', 'name': 'Transfer Bank'},
  ];

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }

  Future<void> _fetchTokenAndStartPayment() async {
    setState(() => _isLoading = true);

    try {
      // Debug item yang dikirim
      print("=== ITEMS ===");
      for (var item in widget.items) {
        print(item);
      }

      final response = await Supabase.instance.client.functions.invoke(
        'create_payment',
        body: {
          'total_price': widget.totalPrice,
          'nama_customer': widget.namaCustomer,
          'items': widget.items,
          'payment_type': _selectedPayment,
        },
      );
      final url = response.data['redirect_url'];
      if (url == null) {
        throw Exception("redirect_url tidak ditemukan");
      }

      print("=== RESPONSE ===");
      print(response.data);

      if (response.status != 200) {
        throw Exception(response.data['error'] ?? 'Gagal membuat transaksi');
      }

      final paymentUrl = response.data['redirect_url'];
      final orderNumber = response.data['order_number'];

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MidtransWebViewPage(
            paymentUrl: paymentUrl,
            orderNumber: orderNumber,
          ),
        ),
      );

      final token = response.data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception("Token Midtrans kosong");
      }
    } catch (e) {
      print(e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text("Checkout"),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Customer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.orange),
                      const SizedBox(width: 10),
                      Text(
                        widget.namaCustomer,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih Metode Pembayaran
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Metode Pembayaran",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedPayment,
                        underline: const SizedBox(),
                        items: _paymentOptions.map((opt) {
                          return DropdownMenuItem(
                            value: opt['id'],
                            child: Text(opt['name']!),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedPayment = val!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Daftar Item
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pesanan",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      ...widget.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${item['qty']}x ${item['nama']}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              "Rp ${_formatPrice(item['subtotal'] ?? (item['harga'] * item['qty']))}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Panel Total + Tombol Bayar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rp ${_formatPrice(widget.totalPrice)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: "Bayar Sekarang",
                    backgroundColor: AppColors.orange,
                    isLoading: _isLoading,
                    onPressed: _fetchTokenAndStartPayment,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}