import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class _UserOrderHistoryScreenState extends State<UserOrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: const Text('Aktivitas', style: AppTextStyles.judul),
          centerTitle: false,
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.orange,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam proses'),
              Tab(text: 'Siap Diambil'),
              Tab(text: 'Selesai'),
            ],
          ),
        ),
        body: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state is OrderLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.orange),
              );
            }
            if (state is OrderFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    state.errorMessage,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state is OrderHistoryLoadSuccess) {
              final allOrders = state.orders;

              final inProgressOrders = allOrders.where((order) => 
                order.status == 'pending' || order.status == 'proses'
              ).toList();

              final readyToPickOrders = allOrders.where((order) => 
                order.status == 'siap diambil'
              ).toList();

              final completedOrders = allOrders.where((order) => 
                order.status == 'selesai'
              ).toList();

              return TabBarView(
                children: [
                  // TAB 1: SEMUA PESANAN
                  _buildTabContent(
                    orders: allOrders,
                    emptyWidget: const EmptyStateWidget(
                      icon: Icons.assignment_outlined,
                      title: 'Belum Ada Aktivitas',
                      description: 'Kamu belum melakukan pemesanan burger nih. Yuk, mulai pesan burger pertamamu!',
                    ),
                  ),

                  // TAB 2: DALAM PROSES
                  _buildTabContent(
                    orders: inProgressOrders,
                    emptyWidget: const EmptyStateWidget(
                      icon: Icons.cookie_outlined,
                      title: 'Tidak Ada Proses',
                      description: 'Saat ini tidak ada burger yang sedang dimasak oleh koki kami.',
                    ),
                  ),

                  // TAB 3: SIAP DIAMBIL
                  _buildTabContent(
                    orders: readyToPickOrders,
                    emptyWidget: const EmptyStateWidget(
                      icon: Icons.shopping_bag_outlined,
                      title: 'Belum Ada yang Siap',
                      description: 'Silakan tunggu sebentar, pesananmu akan segera muncul di sini jika sudah matang.',
                    ),
                  ),

                  // TAB 4: SELESAI
                  _buildTabContent(
                    orders: completedOrders,
                    emptyWidget: const EmptyStateWidget(
                      icon: Icons.receipt_long_outlined,
                      title: 'Riwayat Kosong',
                      description: 'Kamu belum memiliki transaksi pemesanan yang selesai.',
                    ),
                  ),
                ],
              );
            }

            return const Center(
              child: Text('Memuat aktivitas...', style: AppTextStyles.bodyRegular),
            );
          },
        ),
      ),
    );
  }

  // Widget Helper untuk merender list pesanan atau empty state kustom
  Widget _buildTabContent({required List<OrderModel> orders, required Widget emptyWidget}) {
    if (orders.isEmpty) {
      return emptyWidget;
    }

    return RefreshIndicator(
      color: AppColors.orange,
      onRefresh: () async {
        context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          return _buildHistoryCard(orders[index]);
        },
      ),
    );
  }

  Widget _buildHistoryCard(OrderModel order) {
    bool isSelesai = order.status == 'selesai';
    bool isMenuTersedia = true;

    Color badgeColor = AppColors.warning;
    String statusLabel = "Diproses";

    if (order.payment_status == 'pending') {
      badgeColor = AppColors.info;
      statusLabel = "Menunggu Pembayaran";
    } else if (isSelesai) {
      badgeColor = AppColors.success;
      statusLabel = "Pesanan Selesai";
    } else if (order.status == 'siap diambil') {
      badgeColor = AppColors.success;
      statusLabel = "Siap Diambil";
    }

    return CustomCard(
      badgeText: statusLabel,
      badgeColor: badgeColor,
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OrderTrackingScreen(order: order),
        //   ),
        // ).then((_) {
        //   // Refresh data saat kembali dari halaman tracking
        //   context.read<OrderBloc>().add(LoadUserOrderHistoryEvent());
        // });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "11 Jun, 15:03", 
            style: AppTextStyles.bodyRegular.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lunch_dining, color: AppColors.darkRed, size: 28),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.nama_customer ?? 'Pelanggan MoBurger',
                      style: AppTextStyles.judul.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tipe: ${order.order_type.toUpperCase()}',
                      style: AppTextStyles.bodyRegular.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              Text(
                'Rp ${order.total_price}',
                style: AppTextStyles.formLabel.copyWith(fontSize: 14, color: AppColors.black),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isSelesai) ...[
                SizedBox(
                  width: 135,
                  height: 36,
                  child: PrimaryButton(
                    text: isMenuTersedia ? 'Pesan lagi' : 'Tidak tersedia',
                    backgroundColor: isMenuTersedia ? AppColors.orange : Colors.grey.shade400,
                    borderRadius: 20, 
                    onPressed: isMenuTersedia 
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Menambahkan menu yang sama ke checkout...')),
                            );
                          }
                        : null,
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: 135,
                  height: 36,
                  child: PrimaryButton(
                    text: 'Detail Lacak',
                    backgroundColor: AppColors.white, 
                    textColor: AppColors.orange,      
                    borderRadius: 20,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}