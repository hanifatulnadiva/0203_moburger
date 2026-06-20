import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/data/models/order_item_topping_model.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:moburger/ui/order/pemantauan/pemantauan_pesanan.dart';

class OrderDetailPage extends StatefulWidget {
  final OrderModel order;

  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  @override
  void initState() {
    super.initState();
    // Hanya panggil event jika belum ada data success di state BLoC
    final currentState = context.read<OrderBloc>().state;
    if (currentState is! OrderDetailLoadSuccess) {
      context.read<OrderBloc>().add(LoadOrderDetailEvent(widget.order.id));
    }
  }

  Future<void> _navigateToTracking(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(orderNumber: order.order_number),
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
        title: Text(
          "Order #${widget.order.order_number}",
          style: AppTextStyles.judul,
        ),
        foregroundColor: AppColors.darkRed,
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage)),
            );
          }
        },
        builder: (context, state) {
          // 1. Tampilkan Loading hanya jika belum ada data sama sekali
          if (state is OrderLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }

          // 2. Data Sukses (Detail)
          if (state is OrderDetailLoadSuccess) {
            return _buildOrderDetailUI(state.items);
          }

          // 3. Tangani State dari Tracking agar tidak kembali ke "Silakan tunggu"
          if (state is OrderWatchSuccess) {
            // Kita coba akses items dari model order yang dibawa state ini
            // Pastikan model Anda mendukung pengaksesan list item dari object order
            final items = (state.order.items ?? []) as List<OrderItemTopping>;
            return _buildOrderDetailUI(items);
          }

          // 4. Error
          if (state is OrderFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(state.errorMessage, textAlign: TextAlign.center),
                  ),
                  ElevatedButton(
                    onPressed: () => context.read<OrderBloc>().add(LoadOrderDetailEvent(widget.order.id)),
                    child: const Text("Coba Lagi"),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text("Memuat data..."));
        },
      ),
    );
  }

  Widget _buildOrderDetailUI(List<OrderItemTopping> items) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildOrderInfoCard(items),
          const SizedBox(height: 20),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(List<OrderItemTopping> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow("Customer", widget.order.nama_customer ?? '-'),
          _infoRow("Pembayaran", widget.order.payment_status.toUpperCase()),
          _infoRow("Status", widget.order.status.toUpperCase()),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              "Detail Pesanan:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          ...items.map((item) => _buildOrderItemRow(item)).toList(),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Bayar:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkRed)),
              Text("Rp ${widget.order.total_price}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkRed)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemRow(OrderItemTopping item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: Text(item.menuName, style: AppTextStyles.bodyRegular)),
          Expanded(flex: 1, child: Center(child: Text("${item.quantity}x"))),
          Expanded(flex: 2, child: Text("Rp${item.price.toInt()}", textAlign: TextAlign.right)),
          Expanded(flex: 2, child: Text("Rp${item.subTotal.toInt()}", textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.bodyRegular),
      ],
    ),
  );

  Widget _buildActionButtons(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: AppColors.white),
        onPressed: () => _navigateToTracking(widget.order),
        child: const Text("Lacak Pesanan"),
      ),
    );
  }
}