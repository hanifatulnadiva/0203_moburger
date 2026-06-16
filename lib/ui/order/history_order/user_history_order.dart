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
import 'package:moburger/ui/order/order_detail/detail_order.dart';

class UserOrderHistoryScreen extends StatefulWidget {
  const UserOrderHistoryScreen({super.key});

  @override
  State<UserOrderHistoryScreen> createState() => _UserOrderHistoryScreenState();
}

class _UserOrderHistoryScreenState extends State<UserOrderHistoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final state = context.read<OrderBloc>().state;
    if (state is! OrderHistoryLoadSuccess) {
      context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // FIX: Length set to 4 to match the 4 tabs and 4 body views
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
              return TabBarView(children: [
                _buildTabContent(all),
                // Combined pending and diprosess for "Dalam Proses"
                _buildTabContent(all.where((o) => o.status == 'pending' || o.status == 'diprosess').toList()),
                _buildTabContent(all.where((o) => o.status == 'siap diambil').toList()),
                _buildTabContent(all.where((o) => o.status == 'selesai').toList()),
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

  Widget _buildTabContent(List<OrderModel> orders) {
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
        context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: orders.length,
        itemBuilder: (context, i) => _buildHistoryCard(orders[i]),
      ),
    );
  }

  Widget _buildHistoryCard(OrderModel order) {
    bool isSelesai = order.status == 'selesai';
    bool isPending = order.payment_status == 'pending';
    String date = DateFormat('dd MMM, HH:mm').format(DateTime.parse(order.createdAt));

    String statusLabel = isPending ? "Menunggu Pembayaran" : (isSelesai ? "Selesai" : "Diproses");
    Color badgeColor = isPending ? AppColors.info : (isSelesai ? AppColors.success : AppColors.warning);

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
              const SizedBox(width: 14),
              // FIX: Wrapped in Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.nama_customer ?? 'Pelanggan',
                      style: AppTextStyles.judul.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tipe: ${order.order_type.toUpperCase()}',
                      style: AppTextStyles.bodyRegular.copyWith(fontSize: 12),
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
        // Logic navigation
      },
    );
  }
}