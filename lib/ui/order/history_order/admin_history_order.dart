import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/card_order.dart';
import 'package:moburger/core/widget/custom_card.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_status_card.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/data/models/order_model.dart';

class AdminOrderHistoryScreen extends StatefulWidget {
  const AdminOrderHistoryScreen({super.key});

  @override
  State<AdminOrderHistoryScreen> createState() => _AdminOrderHistoryScreenState();
}

class _AdminOrderHistoryScreenState extends State<AdminOrderHistoryScreen> {
  static const int _itemsPerPage = 10;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
  }

  void _refresh() {
    setState(() => _currentPage = 0);
    context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderStatusUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status pesanan berhasil diperbarui!'),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }

          if (state is OrderFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(state.errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
              ),
            );
          }

          if (state is OrderHistoryLoadSuccess) {
            // Filter: Abaikan status 'pending'
            final activeOrders = state.orders
                .where((o) => o.status != 'pending')
                .toList()
                .reversed
                .toList();

            final totalActive = activeOrders.length;
            final selesai = activeOrders.where((o) => o.status == 'selesai').length;
            final diprosess = activeOrders.where((o) => o.status == 'diprosess').length;
            final siap = activeOrders.where((o) => o.status == 'siap diambil').length;

            if (activeOrders.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.storefront_outlined,
                title: 'Antrean Kosong',
                description: 'Tidak ada pesanan aktif saat ini.',
              );
            }

            final totalPages = (activeOrders.length / _itemsPerPage).ceil();
            int safePage = _currentPage >= totalPages ? (totalPages - 1).clamp(0, totalPages - 1) : _currentPage;
            final startIndex = safePage * _itemsPerPage;
            final pagedOrders = activeOrders.sublist(startIndex, (startIndex + _itemsPerPage).clamp(0, activeOrders.length));

            return RefreshIndicator(
              color: AppColors.orange,
              onRefresh: () async => _refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top:16, right:16, left:16, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusGrid(totalActive, diprosess, selesai),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Statistik Pesanan', Icons.pie_chart_rounded),
                    const SizedBox(height: 12),
                    _buildPieChart(proses: diprosess, siap: siap, selesai: selesai),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Antrean Pesanan Aktif', Icons.list_alt_rounded),
                    const SizedBox(height: 12),
                    ...pagedOrders.map((order) => AdminOrderCard(order: order)),
                    if (totalPages > 1) _buildPaginationControls(safePage, totalPages),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ===== OPTION CARD UNTUK STATISTIK =====
  Widget _buildStatusGrid(int total, int proses, int selesai) {
    return Row(
      children: [
        Expanded(child: OptionCard(label: 'Total Aktif', value: '$total', icon: Icons.receipt_long, color: AppColors.darkRed)),
        const SizedBox(width: 12),
        Expanded(child: OptionCard(label: 'Dalam Proses', value: '$proses', icon: Icons.fire_truck, color: AppColors.orange)),
        const SizedBox(width: 12),
        Expanded(child: OptionCard(label: 'Selesai', value: '$selesai', icon: Icons.check_circle, color: AppColors.success)),
      ],
    );
  }

  // ===== COMPONENTS =====
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: AppColors.background,
    title: const Text('Manajemen Order', style: AppTextStyles.judul),
    actions: [IconButton(icon: const Icon(Icons.refresh, color: AppColors.white), onPressed: _refresh)],
  );

  Widget _buildSectionHeader(String title, IconData icon) => Row(
    children: [
      Icon(icon, color: AppColors.orange, size: 20),
      const SizedBox(width: 10),
      Text(title, style: AppTextStyles.judul),
    ],
  );

  // Widget _buildAdminOrderCard(OrderModel order) {
  //   // Logika tombol update status
  //   String? nextAction;
  //   String? nextStatus;
  //   if (order.status == 'diprosess') { nextAction = 'Siap Diambil'; nextStatus = 'siap diambil'; }
  //   else if (order.status == 'siap diambil') { nextAction = 'Selesaikan'; nextStatus = 'selesai'; }

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 14),
  //     child: CustomCard(
  //       badgeText: order.status.toUpperCase(),
  //       badgeColor: _statusBadgeColor(order.status),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: AppTextStyles.formLabel),
  //           const SizedBox(height: 8),
  //           Text('Pelanggan: ${order.nama_customer ?? 'Umum'}', style: AppTextStyles.bodyRegular),
  //           Text('Total: Rp ${order.total_price}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkRed)),
  //           if (nextAction != null) ...[
  //             const SizedBox(height: 12),
  //             PrimaryButton(
  //               text: nextAction,
  //               onPressed: () => context.read<OrderBloc>().add(UpdateOrderStatusEvent(orderId: order.id, status: nextStatus!)),
  //             ),
  //           ]
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // ===== PIE CHART =====
  Widget _buildPieChart({required int proses, required int siap, required int selesai}) {
    final total = proses + siap + selesai;
    if (total == 0) return const SizedBox.shrink();

    return CustomCard(
      child: Row(
        children: [
          SizedBox(
            width: 110,
            height: 110,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 28,
                sections: [
                  PieChartSectionData(
                    color: AppColors.orange,
                    value: proses.toDouble(),
                    title: '$proses',
                    radius: 22,
                    titleStyle: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: AppColors.yellow,
                    value: siap.toDouble(),
                    title: '$siap',
                    radius: 22,
                    titleStyle: const TextStyle(color: AppColors.darkRed, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  PieChartSectionData(
                    color: AppColors.success,
                    value: selesai.toDouble(),
                    title: '$selesai',
                    radius: 22,
                    titleStyle: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIndicator(color: AppColors.orange, text: 'Dalam Proses '),
                const SizedBox(height: 8),
                _buildIndicator(color: AppColors.yellow, text: 'Siap Diambil'),
                const SizedBox(height: 8),
                _buildIndicator(color: AppColors.success, text: 'Selesai'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIndicator({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodyRegular.copyWith(fontSize: 12, color: AppColors.black))),
      ],
    );
  }

  // ===== STATUS COLOR HELPERS =====
  Color _statusBadgeColor(String status) {
    switch (status) {
      case 'diprosess': return AppColors.orange;
      case 'siap diambil': return AppColors.info;
      case 'selesai': return AppColors.success;
      default: return Colors.grey;
    }
  }

  Color _statusStripeColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.darkRed;
      case 'diprosess':
        return AppColors.orange;
      case 'siap diambil':
        return AppColors.yellow;
      case 'selesai':
        return AppColors.success;
      default:
        return Colors.grey;
    }
  }

  // ===== CARD ITEM ORDER =====
  // Widget _buildAdminOrderCard(OrderModel order) {
  //   String? nextActionText;
  //   String? nextStatusTarget;
  //   Color buttonColor = AppColors.orange;

  //   if (order.payment_status == 'settlement' || order.payment_status == 'success') {
  //     switch (order.status) {
  //       case 'pending':
  //         nextActionText = 'Proses Pesanan';
  //         nextStatusTarget = 'proses';
  //         buttonColor = AppColors.orange;
  //         break;
  //       case 'proses':
  //         nextActionText = 'Siap Diambil';
  //         nextStatusTarget = 'siap diambil';
  //         buttonColor = AppColors.info;
  //         break;
  //       case 'siap diambil':
  //         nextActionText = 'Selesaikan Pesanan';
  //         nextStatusTarget = 'selesai';
  //         buttonColor = AppColors.success;
  //         break;
  //     }
  //   }

  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 14),
  //     child: Container(
  //       decoration: BoxDecoration(
  //         border: Border(left: BorderSide(color: _statusStripeColor(order.status), width: 5)),
  //         borderRadius: BorderRadius.circular(16),
  //       ),
  //       child: CustomCard(
  //         badgeText: order.status.toUpperCase(),
  //         badgeColor: _statusBadgeColor(order.status),
  //         onTap: () {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Membuka detail order admin untuk #${order.id.substring(0, 8)}')),
  //           );
  //         },
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Order #${order.id.substring(0, 8).toUpperCase()}', style: AppTextStyles.formLabel),
  //             const SizedBox(height: 8),
  //             Text('Pelanggan: ${order.nama_customer ?? 'Pelanggan Offline'}', style: AppTextStyles.bodyRegular),
  //             const SizedBox(height: 2),
  //             Row(
  //               children: [
  //                 Icon(
  //                   order.order_type.toLowerCase() == 'delivery'
  //                       ? Icons.delivery_dining_rounded
  //                       : Icons.storefront_rounded,
  //                   size: 14,
  //                   color: AppColors.textSecondary,
  //                 ),
  //                 const SizedBox(width: 4),
  //                 Text('Tipe: ${order.order_type.toUpperCase()}', style: AppTextStyles.bodyRegular),
  //               ],
  //             ),
  //             const SizedBox(height: 6),
  //             Text(
  //               'Total: Rp ${order.total_price}',
  //               style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.darkRed, fontSize: 15),
  //             ),

  //             if (nextActionText != null && nextStatusTarget != null) ...[
  //               const SizedBox(height: 12),
  //               const Divider(height: 1, thickness: 0.5),
  //               const SizedBox(height: 12),
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: PrimaryButton(
  //                   text: nextActionText,
  //                   backgroundColor: buttonColor,
  //                   borderRadius: 8,
  //                   onPressed: () {
  //                     context.read<OrderBloc>().add(
  //                           UpdateOrderStatusEvent(
  //                             orderId: order.id,
  //                             status: nextStatusTarget!,
  //                           ),
  //                         );
  //                   },
  //                 ),
  //               ),
  //             ]
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ===== PAGINATION CONTROLS =====
  Widget _buildPaginationControls(int currentPage, int totalPages) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _pageNavButton(
            icon: Icons.chevron_left_rounded,
            enabled: currentPage > 0,
            onTap: () => setState(() => _currentPage = currentPage - 1),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(totalPages, (i) => _pageNumberButton(i, currentPage)),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _pageNavButton(
            icon: Icons.chevron_right_rounded,
            enabled: currentPage < totalPages - 1,
            onTap: () => setState(() => _currentPage = currentPage + 1),
          ),
        ],
      ),
    );
  }

  Widget _pageNavButton({required IconData icon, required bool enabled, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.darkRed.withOpacity(0.08) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? AppColors.darkRed : AppColors.textSecondary.withOpacity(0.3)),
      ),
    );
  }

  Widget _pageNumberButton(int index, int currentPage) {
    final bool isActive = index == currentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _currentPage = index),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.orange : AppColors.white,
            border: Border.all(color: isActive ? AppColors.orange : AppColors.orange.withOpacity(0.25)),
            shape: BoxShape.circle,
          ),
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isActive ? AppColors.white : AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}