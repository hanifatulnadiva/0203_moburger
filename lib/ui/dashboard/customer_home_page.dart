import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_header.dart';
import 'package:moburger/core/widget/custom_navbar.dart';
import 'package:moburger/ui/auth/login_page.dart';
import 'package:moburger/ui/dashboard/home_page.dart';
import 'package:moburger/ui/order/history_order/admin_history_order.dart';
import 'package:moburger/ui/order/history_order/user_history_order.dart';
import 'package:moburger/ui/menu/admin_menu.dart';
import 'package:moburger/ui/menu/customer_menu.dart';
import 'package:moburger/ui/order/order_detail/cart_page.dart';
import 'package:moburger/ui/profile/profile_page.dart';
import 'package:moburger/ui/report/laporan_penjualan.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final String userRole;

  const CustomerDashboardScreen({super.key, required this.userRole});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  late TabKey _activeTab;
  final TextEditingController _searchController = TextEditingController();

  List<TabKey> _getTabsByRole() {
    if (widget.userRole == 'admin') {
      return [TabKey.dashboard, TabKey.order, TabKey.menu, TabKey.report, TabKey.profile];
    } else {
      return [TabKey.home, TabKey.menu, TabKey.cart, TabKey.order, TabKey.profile];
    }
  }

  @override
  void initState() {
    super.initState();
    _activeTab = widget.userRole == 'admin' ? TabKey.dashboard : TabKey.home;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabsByRole();
    final activeIndex = tabs.contains(_activeTab) ? tabs.indexOf(_activeTab) : 0;

    // Pindahkan listener ke sini agar bisa mengontrol navigasi dari level atas
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is Unauthenticated,
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        extendBody: true,
        body: IndexedStack(
          index: activeIndex,
          children: tabs.map((tab) => _buildPageContent(tab)).toList(),
        ),
        bottomNavigationBar: CustomBottomBar(
          activeTab: _activeTab,
          userRole: widget.userRole,
          onTabPress: (TabKey selectedTab) {
            setState(() {
              _activeTab = selectedTab;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(TabKey tab) {
    switch (tab) {
      case TabKey.home:
        return _buildHomeDashboardContent();
      case TabKey.dashboard:
        return AdminDashboardScreen();
      case TabKey.menu:
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated && authState.user.role == 'admin') {
          return const AdminMenuScreen();
        } else {
          return const CustomerMenuScreen();
        }
      case TabKey.cart:
        return const CartScreen();
      case TabKey.report:
        return const ReportScreen();
      case TabKey.order:
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          return authState.user.role == 'admin' ? const AdminOrderHistoryScreen() : const UserOrderHistoryScreen();
        }
        return const Center(child: Text("Silakan login"));
      case TabKey.profile:
        return BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return ProfileScreen(user: state.user);
            }
            return const SizedBox.shrink();
          },
        );
      }
    }  // ==================== STRUKTUR UTAMA DASHBOARD (HOME) ====================
  Widget _buildHomeDashboardContent() {
    return Column(
      children: [
        DashboardHeader(
          searchController: _searchController,
          userRole: widget.userRole,
          onSearchChanged: (val) {},
          onSearchClear: () {
            _searchController.clear();
          },
          onRightActionTap: () {
            setState(() => _activeTab = TabKey.profile);
          },
          onFilterOrScanTap: () {},
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildPromoCarousel(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Kategori Menu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                //_buildCategoryList(),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Menu Terlaris 🔥',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildBestSellerGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ==================== INLINE SUB-COMPONENTS ====================
  Widget _buildPromoCarousel() {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        itemCount: 3,
        controller: PageController(viewportFraction: 0.88),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: index == 0 ? AppColors.darkRed : AppColors.orange,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  const Positioned(
                    right: -20,
                    bottom: -10,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        Icons.fastfood,
                        size: 180,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'PROMO JUARA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Diskon Hingga 35%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Khusus Pembelian via Aplikasi MoBurger',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Widget _buildCategoryList() {
  //   return SizedBox(
  //     height: 40,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       physics: const BouncingScrollPhysics(),
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       itemCount: _categories.length,
  //       itemBuilder: (context, index) {
  //         bool isSelected = _selectedCategoryIndex == index;
  //         return Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4.0),
  //           child: ChoiceChip(
  //             label: Text(_categories[index]),
  //             selected: isSelected,
  //             showCheckmark: false,
  //             selectedColor: AppColors.darkRed,
  //             backgroundColor: AppColors.white,
  //             labelStyle: TextStyle(
  //               color: isSelected ? Colors.white : AppColors.textSecondary,
  //               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
  //             ),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //               side: BorderSide(
  //                 color: isSelected ? Colors.transparent : Colors.black12,
  //               ),
  //             ),
  //             onSelected: (bool selected) {
  //               setState(() {
  //                 _selectedCategoryIndex = index;
  //               });
  //             },
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildBestSellerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Icon(
                      Icons.lunch_dining_rounded,
                      size: 70,
                      color: AppColors.orange,
                    ),
                  ),
                ),
                const Text(
                  'Cheese Burger Super',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Daging sapi asli + keju lumer',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Rp 32.000',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.orange,
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.darkRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
