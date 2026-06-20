import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/bloc/order/order_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/order/order_state.dart';
import 'package:moburger/bloc/order/order_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/card_order.dart';
import 'package:moburger/core/widget/custom_header.dart';
import 'package:moburger/core/widget/custom_status_card.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/core/widget/kategori_filter.dart';
import 'package:moburger/ui/menu/customer_menu.dart';
import 'package:moburger/ui/profile/profile_page.dart';
import 'package:moburger/ui/topping/list_topping.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'diprosess'; 
  final List<String> _categories = ['diprosess', 'siap diambil', 'selesai'];

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderStatusUpdateSuccess) {
            context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Status pesanan berhasil diperbarui!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              DashboardHeader(
                searchController: _searchController, 
                userRole: 'admin',
                onSearchChanged: (value) {
                  if (value.trim().isEmpty) {
                    context.read<OrderBloc>().add(LoadAdminOrderHistoryEvent());
                  } else {
                    context.read<OrderBloc>().add(
                      SearchOrderRequested(value),
                    );
                  }
                },
                onRightActionTap: () {
                  final authState = context.read<AuthBloc>().state;

                  if (authState is Authenticated) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(
                          user: authState.user,
                        ),
                      ),
                    );
                  }
                },
              ),
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
                    
                    KategoriFilter(
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      onSelected: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildOrderList(),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        int proses = 0, siap = 0, selesai = 0;
        if (state is OrderHistoryLoadSuccess) {
          proses = state.orders.where((o) => o.status == 'diprosess').length;
          siap = state.orders.where((o) => o.status == 'siap diambil').length;
          selesai = state.orders.where((o) => o.status == 'selesai').length;
        }
        return Row(
          children: [
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
          // Filter hanya berdasarkan kategori terpilih (tanpa 'Semua')
          final filteredOrders = state.orders.where((o) {
            return o.status == _selectedCategory;
          }).toList();
          
          if (filteredOrders.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.receipt_long_outlined, 
              title: "Belum Ada Pesanan", 
              description: "Tidak ada pesanan dengan status '$_selectedCategory'."
            );
          }
          final recentOrders = filteredOrders.reversed.take(5).toList();
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentOrders.length,
            itemBuilder: (context, index) => AdminOrderCard(order: recentOrders[index]),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}