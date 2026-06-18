import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/ui/order/pemantauan/qr_screen.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/data/models/order_item_details_model.dart';
import 'package:moburger/data/repositories/order_repository.dart';

class OrderTrackingPage extends StatefulWidget {
  final String orderNumber;

  const OrderTrackingPage({super.key, required this.orderNumber});

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  // Variabel untuk menyimpan data agar tidak fetch ulang terus-menerus
  List<OrderItemWithDetails>? _cachedItems;
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
    // 1. Pantau status via Bloc
    context.read<OrderBloc>().add(WatchOrderEvent(orderId: widget.orderNumber));
    
    // 2. Fetch detail sekali saja
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      final items = await OrderRepository().getOrderDetail(widget.orderNumber);
      if (mounted) {
        setState(() {
          _cachedItems = items;
          _isLoadingItems = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingItems = false);
      print("Error fetching details: $e");
    }
  }

  String _formatPrice(num price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  String _formatDateTime(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '-';
    const bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${bulan[date.month - 1]} ${date.year}, $jam:$menit';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text("Order #${widget.orderNumber}", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }

          if (state is OrderWatchSuccess) {
            final order = state.order;
            final statusIndex = state.statusIndex;

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMenuCarousel(),
                const SizedBox(height: 24),
                const Text("Status Pesanan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                
                _buildTimelineTile(index: 0, icon: Icons.payments_outlined, title: 'Menunggu Pembayaran', description: 'Selesaikan pembayaran.', statusIndex: statusIndex, timestamp: statusIndex == 0 ? order.createdAt : '', isFirst: true),
                _buildTimelineTile(index: 1, icon: Icons.check_circle_outline, title: 'Pembayaran Diterima', description: 'Pembayaran diterima.', statusIndex: statusIndex, timestamp: statusIndex == 1 ? order.updateAt : ''),
                _buildTimelineTile(index: 2, icon: Icons.outdoor_grill_outlined, title: 'Pesanan Diproses', description: 'Koki menyiapkan pesanan.', statusIndex: statusIndex, timestamp: statusIndex == 2 ? order.updateAt : ''),
                _buildTimelineTile(index: 3, icon: Icons.shopping_bag_outlined, title: 'Pesanan Siap Diambil', description: 'Pesanan sudah siap.', statusIndex: statusIndex, timestamp: statusIndex == 3 ? order.updateAt : '', extra: statusIndex == 3 ? _buildQrButton(order.order_number) : null),
                _buildTimelineTile(index: 4, icon: Icons.emoji_food_beverage_outlined, title: 'Pesanan Selesai', description: 'Selamat menikmati!', statusIndex: statusIndex, timestamp: statusIndex == 4 ? order.updateAt : '', isLast: true),
              ],
            );
          }
          if (state is OrderFailure) {
            return Center(child: Text("Error: ${state.errorMessage}"));
          }
          return const Center(child: CircularProgressIndicator(color: AppColors.orange));
        },
      ),
    );
  }

  Widget _buildMenuCarousel() {
    if (_isLoadingItems) {
      return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator(color: AppColors.orange)));
    }
    if (_cachedItems == null || _cachedItems!.isEmpty) return const SizedBox.shrink();

    final items = _cachedItems!;
    if (items.length == 1) return _buildMenuItemCard(items.first);

    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.85),
        itemCount: items.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: _buildMenuItemCard(items[index]),
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(OrderItemWithDetails item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.darkRed.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: item.imageUrl != null
                ? Image.network(item.imageUrl!, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _menuPlaceholderIcon())
                : _menuPlaceholderIcon(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.menuName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${item.quantity}x • ${_formatPrice(item.price)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuPlaceholderIcon() {
    return Container(width: 64, height: 64, color: AppColors.darkRed.withOpacity(0.08), child: const Icon(Icons.lunch_dining, color: AppColors.darkRed, size: 28));
  }

  Widget _buildQrButton(String orderNumber) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          icon: const Icon(Icons.qr_code_rounded, size: 20),
          label: const Text("Lihat Kode Pengambilan"),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderQrPage(orderNumber: orderNumber))),
        ),
      ),
    );
  }

  Widget _buildTimelineTile({
    required int index, required IconData icon, required String title,
    required String description, required int statusIndex, required String timestamp,
    Widget? extra, bool isFirst = false, bool isLast = false,
  }) {
    final bool isDone = index <= statusIndex;
    final Color activeColor = AppColors.orange;
    final Color inactiveColor = Colors.grey.shade300;

    return TimelineTile(
      isFirst: isFirst, isLast: isLast,
      indicatorStyle: IndicatorStyle(width: 32, height: 32, color: isDone ? activeColor : inactiveColor, iconStyle: IconStyle(iconData: icon, color: isDone ? AppColors.white : Colors.grey.shade500, fontSize: 16)),
      beforeLineStyle: LineStyle(color: isDone ? activeColor : inactiveColor, thickness: 3),
      afterLineStyle: LineStyle(color: isDone ? activeColor : inactiveColor, thickness: 3),
      endChild: Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 24, top: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: index == statusIndex ? FontWeight.bold : FontWeight.w600, fontSize: 14)),
            Text(description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (timestamp.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(_formatDateTime(timestamp), style: const TextStyle(fontSize: 11, color: AppColors.orange, fontWeight: FontWeight.w600)),
            ],
            if (extra != null) extra,
          ],
        ),
      ),
    );
  }
}