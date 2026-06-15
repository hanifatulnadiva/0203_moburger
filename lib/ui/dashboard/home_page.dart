import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_header.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/core/widget/custom_navbar.dart';
import 'package:moburger/core/widget/custom_status_card.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:moburger/ui/menu/admin_menu.dart';
import 'package:moburger/ui/menu/customer_menu.dart';
import 'package:moburger/ui/topping/list_topping.dart';
import 'package:moburger/ui/order/history_order/admin_history_order.dart';
import 'package:moburger/ui/report/laporan_penjualan.dart';
import 'package:moburger/ui/profile/profile_page.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          DashboardHeader(searchController: _searchController, userRole: 'admin'),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Menu Cepat"),
                const SizedBox(height: 12),
                _buildQuickMenuRow(),
                const SizedBox(height: 24),
                _buildSectionTitle("Status Order Hari Ini"),
                const SizedBox(height: 12),
                _buildOrderStatusGrid(),
                const SizedBox(height: 24),
                _buildSectionTitle("Order Terbaru"),
                const SizedBox(height: 12),
                _buildOrderList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuRow() {
    return Row(
      children: [
        Expanded(child: OptionCard(label: "Order Baru", icon: Icons.add_circle, color: AppColors.info, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerMenuScreen())))),
        const SizedBox(width: 12),
        Expanded(child: OptionCard(label: "Topping", icon: Icons.layers, color: AppColors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ToppingPage())))),
      ],
    );
  }

  Widget _buildOrderStatusGrid() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        int pending = 0, proses = 0, siap = 0, selesai = 0;
        if (state is OrderHistoryLoadSuccess) {
          pending = state.orders.where((o) => o.status == 'pending').length;
          proses = state.orders.where((o) => o.status == 'proses').length;
          siap = state.orders.where((o) => o.status == 'siap diambil').length;
          selesai = state.orders.where((o) => o.status == 'selesai').length;
        }
        return Row(
          children: [
            Expanded(child: OptionCard(label: "Pending", value: "$pending", icon: Icons.hourglass_top_rounded, color: AppColors.darkRed)),
            const SizedBox(width: 8),
            Expanded(child: OptionCard(label: "Proses", value: "$proses", icon: Icons.local_fire_department_rounded, color: AppColors.orange)),
            const SizedBox(width: 8),
            Expanded(child: OptionCard(label: "Siap", value: "$siap", icon: Icons.takeout_dining_rounded, color: AppColors.info)),
            const SizedBox(width: 8),
            Expanded(child: OptionCard(label: "Selesai", value: "$selesai", icon: Icons.check_circle_rounded, color: AppColors.success)),
          ],
        );
      },
    );
  }

  Widget _buildOrderList() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) return const Center(child: CircularProgressIndicator());
        if (state is OrderHistoryLoadSuccess) {
          if (state.orders.isEmpty) return EmptyStateWidget(icon: Icons.receipt_long_outlined, title: "Belum Ada Pesanan", description: "Tidak ada pesanan masuk.");
          final recentOrders = List<OrderModel>.from(state.orders).reversed.take(5).toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            itemBuilder: (context, index) => _buildOrderCard(recentOrders[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CustomCard(
        badgeText: order.status.toUpperCase(),
        badgeColor: _statusBadgeColor(order.status),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: AppTextStyles.formLabel),
            const SizedBox(height: 8),
            Text('Pelanggan: ${order.nama_customer ?? 'Umum'}', style: AppTextStyles.bodyRegular),
            const SizedBox(height: 6),
            Text('Total: Rp ${order.total_price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkRed)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Color _statusBadgeColor(String status) {
    switch (status) {
      case 'pending': return AppColors.darkRed;
      case 'proses': return AppColors.orange;
      case 'siap diambil': return AppColors.info;
      case 'selesai': return AppColors.success;
      default: return Colors.grey;
    }
  }
}