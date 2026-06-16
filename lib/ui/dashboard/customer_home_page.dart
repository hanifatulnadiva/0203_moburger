import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/auth/auth_bloc.dart';
import 'package:moburger/bloc/auth/auth_state.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/bloc/cart/cart_state.dart';
import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/bloc/menu/menu_state.dart';
import 'package:moburger/bloc/topping/topping_bloc.dart';
import 'package:moburger/bloc/topping/topping_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_card_menu.dart';
import 'package:moburger/core/widget/custom_header.dart';
import 'package:moburger/core/widget/custom_navbar.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/data/models/menu_model.dart';
import 'package:moburger/ui/auth/login_page.dart';
import 'package:moburger/ui/dashboard/home_page.dart';
import 'package:moburger/ui/menu/detail_menu.dart';
import 'package:moburger/ui/order/history_order/admin_history_order.dart';
import 'package:moburger/ui/order/history_order/user_history_order.dart';
import 'package:moburger/ui/menu/admin_menu.dart';
import 'package:moburger/ui/menu/customer_menu.dart';
import 'package:moburger/ui/order/order_detail/cart_page.dart';
import 'package:moburger/ui/profile/profile_page.dart';
import 'package:moburger/ui/report/laporan_penjualan.dart';
import 'package:moburger/ui/topping/list_topping.dart';

class CustomerDashboardScreen extends StatefulWidget {
  final String userRole;
  final TabKey? initialTab;

  const CustomerDashboardScreen({
    super.key,
    required this.userRole,
    this.initialTab,
  });

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
    _activeTab = widget.initialTab ??
        (widget.userRole == 'admin' ? TabKey.dashboard : TabKey.home);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  bool _hasLevelTopping(BuildContext context) {
    final toppingState = context.read<ToppingBloc>().state;
    return toppingState is ToppingSuccess && toppingState.topping.any((t) => (t.kategori ?? '').toLowerCase() == 'level');
  }
  void _navigateToDetail(BuildContext context, MenuModel item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailMenuScreen(menu: item))).then((_) => setState(() {}));
  }
  void _onTapAddDirectly(BuildContext context, MenuModel item) {
    context.read<CartBloc>().add(AddToCart({
      'ordder_item_id': '${item.id}_default', 'id': item.id.toString(),
      'nama': item.nama_menu ?? 'Menu', 'harga': item.harga, 'qty': 1,
      'level': '', 'toppings': [], 'notes': '',
    }));
  }
  List<Map<String, dynamic>> _getCartItemsByMenuId(List<Map<String, dynamic>> cartItems, String menuId) =>
      cartItems.where((i) => i['id'].toString() == menuId).toList();

  String _formatPrice(dynamic price) => price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabsByRole();
    final activeIndex = tabs.contains(_activeTab) ? tabs.indexOf(_activeTab) : 0;
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
                    style: AppTextStyles.judul
                  ),
                ),
                const SizedBox(height: 12),
                //_buildCategoryList(),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Menu Terbaru", style: AppTextStyles.judul),
                      TextButton(
                        onPressed: () => setState(() => _activeTab = TabKey.menu),
                        child: Text("See All", style: TextStyle(color: AppColors.orange, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _buildCatalogGrid(),
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

  Widget _buildCatalogGrid() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, menuState) {
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (menuState is MenuLoading) return const Center(child: CircularProgressIndicator());
            List<dynamic> menuList = [];
            if (menuState is MenuSuccess) menuList = List.from(menuState.menu).reversed.take(6).toList();
            List<Map<String, dynamic>> cartItems = (cartState is CartLoaded) ? cartState.cartItems : [];
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75,
              ),
              itemCount: menuList.length,
              itemBuilder: (context, index) {
                final item = menuList[index];
                final menuCartItems = _getCartItemsByMenuId(cartItems, item.id.toString());
                final qty = menuCartItems.fold(0, (sum, e) => sum + (e['qty'] as int));
                return MenuCard(
                  item: item, menuId: item.id.toString(), isAvailable: item.tersedia ?? true, currentQty: qty,
                  onTapCard: () => _navigateToDetail(context, item),
                  onTapAction: () {
                    if (item.kategori?.toLowerCase() == 'makanan' || _hasLevelTopping(context)) {
                      _navigateToDetail(context, item);
                    } else {
                      _onTapAddDirectly(context, item);
                    }
                  },
                  formatPrice: _formatPrice,
                );
              },
            );
          },
        );
      },
    );
  }
}
