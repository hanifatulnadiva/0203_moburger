import 'package:flutter/material.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:moburger/ui/order/pemantauan/pemantauan_pesanan.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // Anda bisa menyimpan state lokal di sini, misalnya untuk loading saat bayar
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Order #${widget.order.order_number}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOrderInfoCard(),
            const SizedBox(height: 20),
            Expanded(child: Center(child: Text("Detail Item Pesanan"))),
            const Divider(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Customer: ${widget.order.nama_customer ?? '-'}", 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Status Pembayaran: ${widget.order.payment_status.toUpperCase()}"),
            Text("Status Pesanan: ${widget.order.status.toUpperCase()}"),
            const Divider(),
            Text("Total: Rp ${widget.order.total_price}", 
                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    // 1. Kondisi: Belum Bayar
    if (widget.order.payment_status == 'pending') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : () {
            // Contoh penggunaan setState untuk proses lokal
            setState(() => _isProcessing = true);
            // Logika pembayaran...
          },
          child: _isProcessing 
              ? const CircularProgressIndicator() 
              : const Text("Bayar Sekarang"),
        ),
      );
    } 
    
    // 2. Kondisi: Selesai
    else if (widget.order.status == 'selesai') {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            // Arahkan ke Halaman Nota
          },
          icon: const Icon(Icons.receipt_long),
          label: const Text("Lihat Nota Belanja"),
        ),
      );
    } 
    
    // 3. Kondisi: Sedang Diproses
    else {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderTrackingPage(orderNumber: widget.order.order_number),
              ),
            );
          },
          child: const Text("Pantau Pesanan"),
        ),
      );
    }
  }
}