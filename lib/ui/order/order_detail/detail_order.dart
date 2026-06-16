import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/data/models/order_item_details_model.dart';
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
    context.read<OrderBloc>().add(LoadOrderDetailEvent(widget.order.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text("Order #${widget.order.order_number}", style: AppTextStyles.judul),
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
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }

          if (state is OrderDetailLoadSuccess) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildOrderInfoCard(state.items),
                  const SizedBox(height: 20),
                  _buildActionButtons(context),
                ],
              ),
            );
          }

          return const Center(child: Text("Silakan tunggu..."));
        },
      ),
    );
  }

  Widget _buildOrderInfoCard(List<OrderItemWithDetails> items) {
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
            child: Text("Detail Pesanan:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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

  Widget _buildOrderItemRow(OrderItemWithDetails item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: Text(item.menuName, style: AppTextStyles.bodyRegular)),
              Expanded(flex: 1, child: Center(child: Text("${item.quantity}x"))),
              Expanded(flex: 2, child: Text("Rp${item.price.toInt()}", textAlign: TextAlign.right)),
              Expanded(flex: 2, child: Text("Rp${item.subTotal.toInt()}", 
                  textAlign: TextAlign.right, 
                  style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          if (item.toppingNames.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                "Topping: ${item.toppingNames.join(', ')}",
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
              ),
            ),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OrderTrackingPage(
                orderNumber: widget.order.order_number,
              ),
            ),
          );
        },
        child: const Text("Lacak Pesanan"),
      ),
    );
  }
}