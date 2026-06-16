import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:timeline_tile/timeline_tile.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderNumber;
  const OrderTrackingPage({super.key, required this.orderNumber});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  
  @override
  void initState() {
    super.initState();
    // Memulai proses monitoring saat halaman dibuka
    context.read<OrderBloc>().add(WatchOrderEvent(orderId: widget.orderNumber));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pemantauan Pesanan")),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is OrderWatchSuccess) {
            final int statusIndex = state.statusIndex;

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: [
                      _buildTimelineTile(0, 'Menunggu Pembayaran', statusIndex, isFirst: true),
                      _buildTimelineTile(1, 'Pembayaran Berhasil', statusIndex),
                      _buildTimelineTile(2, 'Makanan Diproses', statusIndex),
                      _buildTimelineTile(3, 'Siap Diambil', statusIndex),
                      _buildTimelineTile(4, 'Selesai', statusIndex, isLast: true),
                    ],
                  ),
                ),
              ],
            );
          }
          
          if (state is OrderFailure) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderHeader(Map<String, dynamic> data) {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pesanan #${widget.orderNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("Total: Rp ${data['total_price']}"),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(int index, String title, int statusIndex, {bool isFirst = false, bool isLast = false}) {
    return TimelineTile(
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 25,
        height: 25,
        color: index <= statusIndex ? Colors.purple : Colors.grey[300]!,
        iconStyle: index <= statusIndex ? IconStyle(iconData: Icons.check, color: Colors.white, fontSize: 16) : null,
      ),
      beforeLineStyle: LineStyle(color: index <= statusIndex ? Colors.purple : Colors.grey[300]!, thickness: 3),
      afterLineStyle: LineStyle(color: index <= statusIndex ? Colors.purple : Colors.grey[300]!, thickness: 3),
      endChild: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(title, style: TextStyle(fontWeight: index == statusIndex ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}