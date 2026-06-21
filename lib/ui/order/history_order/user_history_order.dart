import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:moburger/ui/dashboard/customer_home_page.dart';
import 'package:moburger/ui/menu/customer_menu.dart';
import 'package:moburger/ui/order/order_detail/detail_order.dart';
import 'package:moburger/ui/order/order_detail/midtrans_webview_page.dart';
import 'package:moburger/ui/order/pemantauan/pemantauan_pesanan.dart';

class UserOrderHistoryScreen extends StatefulWidget {
  const UserOrderHistoryScreen({super.key});

  @override
  State<UserOrderHistoryScreen> createState() => _UserOrderHistoryScreenState();
}

class _UserOrderHistoryScreenState extends State<UserOrderHistoryScreen>
  with AutomaticKeepAliveClientMixin {
    final ScrollController _scrollController = ScrollController();
  @override
  bool get wantKeepAlive => true;
  

  @override
  void initState() {
    super.initState();
    final currentState = context.read<OrderBloc>().state;
    if (currentState is! OrderHistoryLoadSuccess) {
      context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
    }
    final state = context.read<OrderBloc>().state;
    if (state is! OrderHistoryLoadSuccess) {
      context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
    }
  }
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Jika mencapai 200px dari bawah, load more
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<OrderBloc>().state;
      // Mencegah load berulang jika sudah loading
      if (state is! OrderLoading) {
        context.read<OrderBloc>().add(LoadUserOrderHistoryEvent(isRefresh: false));
      }
    }
  }

  String _formatPrice(int price) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
  }

  Future<void> _goAndRefresh(Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    if (mounted) {
      context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
    }
  }
  Future<void> _navigateToTracking(OrderModel order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderTrackingPage(orderNumber: order.order_number),
      ),
    );
    
    if (mounted) {
      context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 4, 
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Aktivitas', style: AppTextStyles.judul),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.orange,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam Proses'),
              Tab(text: 'Siap Diambil'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(child: CircularProgressIndicator(color: AppColors.orange));
            }
            if (state is OrderHistoryLoadSuccess) {
              final all = state.orders;
              final reachedMax = state.hasReachedMax;
              return TabBarView(children: [
                _buildTabContent(all,reachedMax),
                _buildTabContent(all.where((o) => o.status == 'diprosess').toList(),true),
                _buildTabContent(all.where((o) => o.status == 'siap diambil').toList(), true),
                _buildTabContent(all.where((o) => o.status == 'selesai').toList(), true),
              ]);
            }
            if (state is OrderFailure) {
              return Center(child: Text(state.errorMessage));
            }
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          },
        ),
      ),
    );
  }

  Widget _buildTabContent(List<OrderModel> orders, bool hasReachedMax) {
    if (orders.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.assignment_outlined,
        title: 'Kosong',
        description: 'Belum ada aktivitas',
      );
    }
    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: () async {
        context.read<OrderBloc>().add(LoadUserOrderHistoryEvent(isRefresh: true));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: hasReachedMax ? orders.length : orders.length + 1,
        itemBuilder: (context, i) {
          if (i < orders.length) {
            return _buildHistoryCard(orders[i]);
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator(color: AppColors.orange)),
            );
          }
        },
      ),
    );
  }

  Widget _buildHistoryCard(OrderModel order) {
    final String status = (order.status ?? '').toLowerCase();
    final bool isSelesai = status == 'selesai';
    final bool isPending = (order.payment_status ?? '').toLowerCase() == 'pending';
    final String date = DateFormat('dd MMM, HH:mm').format(DateTime.parse(order.createdAt));
    
    // Logika Badge yang lebih akurat
    String statusLabel = "Diproses"; // Default
    if (status == 'siap diambil') {
      statusLabel = "Siap Diambil";
    } else if (status == 'selesai') {
      statusLabel = "Selesai";
    } else if (order.payment_status == 'pending') {
      statusLabel = "Menunggu Pembayaran";
    }
    Color badgeColor = AppColors.warning; // Mendefinisikan badgeColor
    if (isPending) {
      statusLabel = "Menunggu Pembayaran";
      badgeColor = AppColors.info;
    } else if (status == 'siap diambil') {
      statusLabel = "Siap Diambil";
      badgeColor = AppColors.orange;
    } else if (isSelesai) {
      statusLabel = "Selesai";
      badgeColor = AppColors.success;
    }
    return CustomCard(
      badgeText: statusLabel,
      badgeColor: badgeColor,
      onTap: () => _goAndRefresh(OrderDetailPage(order: order)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: AppTextStyles.bodyRegular.copyWith(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lunch_dining, color: AppColors.darkRed),
              ),
              const SizedBox(width: 10),
              // FIX: Wrapped in Expanded to prevent overflow
              Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Number
                  Text(
                    'Order: ${order.order_number}',
                    style: AppTextStyles.judul.copyWith(fontSize: 14, color: AppColors.darkRed),
                  ),
                  const SizedBox(height: 4),
                  // Nama Customer
                  Text(
                    order.nama_customer ?? 'Pelanggan',
                    style: AppTextStyles.bodyRegular.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Catatan (Opsional)
                  if (order.notes != null && order.notes!.isNotEmpty)
                    Text(
                      'Catatan: ${order.notes}',
                      style: AppTextStyles.bodyRegular.copyWith(fontSize: 12, fontStyle: FontStyle.italic),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
              const SizedBox(width: 8),
              Text(_formatPrice(order.total_price), style: AppTextStyles.formLabel.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 130,
              height: 36,
              child: _buildActionButton(order, isSelesai, isPending),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(OrderModel order, bool isSelesai, bool isPending) {
    return PrimaryButton(
      text: isPending ? 'Bayar Sekarang' : (isSelesai ? 'Pesan Lagi' : 'Detail'),
      backgroundColor: isPending || isSelesai ? AppColors.orange : AppColors.white,
      textColor: isPending || isSelesai ? AppColors.white : AppColors.orange,
      borderRadius: 20,
      onPressed: () {
        if (isPending) {
          String token = order.snap_token ?? '';
          String url = token.startsWith('http') 
              ? token 
              : "https://app.sandbox.midtrans.com/snap/v2/vtweb/$token"; 

          Navigator.push(context, MaterialPageRoute(builder: (_) => MidtransWebViewPage(
              paymentUrl: url, 
              orderNumber: order.order_number,
          )));

        } else if (isSelesai) {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (_) => const CustomerMenuScreen())
          );
          if (mounted) {
            context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
          }
        } else {
          _navigateToTracking(order);
        }
      },
    );
  }
}