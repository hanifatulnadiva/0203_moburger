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
import 'package:moburger/core/widget/custom_dot_indikator.dart'; // Pastikan path benar
import 'package:moburger/core/widget/custom_header.dart';
import 'package:moburger/core/widget/custom_navbar.dart';
import 'package:moburger/core/widget/kategori_filter.dart';
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

class CustomerDashboardScreen extends StatefulWidget {
  final String userRole;
  final TabKey? initialTab;

  const CustomerDashboardScreen({super.key, required this.userRole, this.initialTab});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  late TabKey _activeTab;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.88);
  
  final List<String> _categories = ['Semua', 'makanan', 'minuman', 'snack'];
  String _selectedCategory = 'Semua';
  String _searchQuery = "";
  int _currentCarouselIndex = 0;
  List<MenuModel> _promoMenus = [];

  @override
  void initState() {
    super.initState();
    _activeTab = widget.initialTab ?? (widget.userRole == 'admin' ? TabKey.dashboard : TabKey.home);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- Helper Methods ---
  bool _hasLevelTopping(BuildContext context) {
    final toppingState = context.read<ToppingBloc>().state;
    return toppingState is ToppingSuccess && toppingState.topping.any((t) => (t.kategori ?? '').toLowerCase() == 'level');
  }
  void _updatePromoMenus(List<MenuModel> allMenus) {
  // Paksa ambil semua menu sebagai promo untuk testing
  final filtered = allMenus.take(3).toList(); 
  if (mounted) {
    setState(() {
      _promoMenus = filtered;
    });
  }
}

  void _navigateToDetail(BuildContext context, MenuModel item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailMenuScreen(menu: item))).then((_) => setState(() {}));
  }

  void _onTapAddDirectly(BuildContext context, MenuModel item) {
    context.read<CartBloc>().add(AddToCart({
      'order_item_id': '${item.id}_default', 'id': item.id.toString(),
      'nama': item.nama_menu ?? 'Menu', 'harga': item.harga, 'qty': 1,
      'level': '', 'toppings': [], 'notes': '',
    }));
  }

  String _formatPrice(dynamic price) => price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  List<dynamic> _getFilteredList(List<dynamic> menuList) {
    List<dynamic> filtered = menuList.where((item) {
      final matchSearch = (item.nama_menu ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategory == 'Semua' || (item.kategori ?? '').toLowerCase() == _selectedCategory.toLowerCase();
      return matchSearch && matchCat;
    }).toList();

    return (_searchQuery.isEmpty && _selectedCategory == 'Semua') 
        ? (filtered.length > 6 ? filtered.reversed.take(6).toList() : filtered.reversed.toList())
        : filtered;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.userRole == 'admin' 
        ? [TabKey.dashboard, TabKey.order, TabKey.menu, TabKey.report, TabKey.profile]
        : [TabKey.home, TabKey.menu, TabKey.cart, TabKey.order, TabKey.profile];
    
    final activeIndex = tabs.contains(_activeTab) ? tabs.indexOf(_activeTab) : 0;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false,
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
        bottomNavigationBar: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            int totalItems = 0;
            if (cartState is CartLoaded) {
              totalItems = cartState.cartItems.fold(0, (sum, item) => sum + (item['qty'] as int));
            }
            return CustomBottomBar(
              activeTab: _activeTab,
              userRole: widget.userRole,
              cartCount: totalItems, 
              onTabPress: (TabKey selectedTab) => setState(() => _activeTab = selectedTab),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageContent(TabKey tab) {
    final authState = context.read<AuthBloc>().state;
    final bool isAdmin = authState is Authenticated && authState.user.role == 'admin';

    switch (tab) {
      case TabKey.home: return _buildHomeDashboardContent();
      case TabKey.dashboard: return AdminDashboardScreen();
      case TabKey.menu: return isAdmin ? const AdminMenuScreen() : const CustomerMenuScreen();
      case TabKey.cart: return const CartScreen();
      case TabKey.report: return const ReportScreen();
      case TabKey.order: return isAdmin ? const AdminOrderHistoryScreen() : const UserOrderHistoryScreen();
      case TabKey.profile: return (authState is Authenticated) ? ProfileScreen(user: authState.user) : const SizedBox.shrink();
    }
  }

  Widget _buildHomeDashboardContent() {
    return Column(
      children: [
        DashboardHeader(
          searchController: _searchController,
          userRole: widget.userRole,
          onSearchChanged: (val) => setState(() => _searchQuery = val),
          onSearchClear: () => setState(() { _searchController.clear(); _searchQuery = ""; }),
          onRightActionTap: () => setState(() => _activeTab = TabKey.profile),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildPromoCarousel(context, _promoMenus),
                const SizedBox(height: 24),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20.0), child: Text('Kategori Menu', style: AppTextStyles.judul)),
                const SizedBox(height: 12),
                KategoriFilter(categories: _categories, selectedCategory: _selectedCategory, onSelected: (cat) => setState(() => _selectedCategory = cat)),
                const SizedBox(height: 12),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: Text("Menu Terbaru", style: AppTextStyles.judul)),
                _buildCatalogGrid(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCarousel(BuildContext context, List<MenuModel> items) {
  return Column(
    children: [
      SizedBox(
        height: 200,
        child: PageView.builder(
          controller: _pageController,
          itemCount: items.length,
          onPageChanged: (i) => setState(() => _currentCarouselIndex = i),
          itemBuilder: (_, i) {
            final menu = items[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => _navigateToDetail(context, menu),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Gambar Background
                      Positioned.fill(
                        child: Image.network(
                          menu.image_url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.orange.withOpacity(0.2)),
                        ),
                      ),
                      // Gradient Overlay agar teks terbaca
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Teks Info
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                menu.kategori.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              menu.nama_menu,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Rp ${_formatPrice(menu.harga)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 12),
      CustomDotIndicator(count: items.length, currentIndex: _currentCarouselIndex),
    ],
  );
}

  Widget _buildCatalogGrid() {
    return BlocBuilder<MenuBloc, MenuState>(builder: (context, menuState) {
      if (menuState is MenuLoading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
      
      final List<MenuModel> allMenu = (menuState is MenuSuccess) ? menuState.menu : [];
    
    // Update promo secara aman
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _promoMenus.isEmpty) {
          _updatePromoMenus(allMenu);
        }
      });
      final displayList = _getFilteredList(allMenu);

      if (displayList.isEmpty) {
        return const EmptyStateWidget(icon: Icons.search_off_rounded, title: "Tidak ditemukan", description: "Coba kata kunci lain.");
      }

      return BlocBuilder<CartBloc, CartState>(builder: (context, cartState) {
        final cartItems = (cartState is CartLoaded) ? cartState.cartItems : <Map<String, dynamic>>[];
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.75),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final item = displayList[index];
            final qty = cartItems.where((i) => i['id'].toString() == item.id.toString()).fold(0, (sum, e) => sum + (e['qty'] as int));
            return MenuCard(
              item: item, menuId: item.id.toString(), isAvailable: item.tersedia ?? true, currentQty: qty,
              onTapCard: () => _navigateToDetail(context, item),
              onTapAction: () => (item.kategori?.toLowerCase() == 'makanan' || _hasLevelTopping(context)) ? _navigateToDetail(context, item) : _onTapAddDirectly(context, item),
              formatPrice: _formatPrice,
            );
          },
        );
      });
    });
  }
}