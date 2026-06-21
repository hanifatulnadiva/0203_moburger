import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/bloc/cart/cart_state.dart';
import 'package:moburger/bloc/menu/menu_event.dart';
import 'package:moburger/bloc/menu/menu_state.dart';
import 'package:moburger/bloc/topping/topping_bloc.dart';
import 'package:moburger/bloc/topping/topping_event.dart';
import 'package:moburger/bloc/topping/topping_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_card_menu.dart';
import 'package:moburger/core/widget/custom_search.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/core/widget/kategori_filter.dart';
import 'package:moburger/core/widget/loading_widget.dart';
import 'package:moburger/data/models/menu_model.dart';
import 'package:moburger/ui/menu/detail_menu.dart';
import 'package:moburger/ui/order/order_detail/cart_page.dart';

class CustomerMenuScreen extends StatefulWidget {
  const CustomerMenuScreen({super.key});

  @override
  State<CustomerMenuScreen> createState() => _CustomerMenuScreenState();
}

class _CustomerMenuScreenState extends State<CustomerMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = ['Semua', 'makanan', 'minuman', 'snack'];
  String _selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchMenu());
    context.read<ToppingBloc>().add(FetchTopping());
    _scrollController.addListener(_onScroll);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }
  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final menuState = context.read<MenuBloc>().state;
      if (menuState is MenuSuccess && !menuState.hasReachedMax) {
        context.read<MenuBloc>().add(LoadMoreMenu());
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuModel> _getFilteredMenus(List<MenuModel> menuList) {
    return menuList.where((menu) {
      final name = (menu.nama_menu ?? '').toLowerCase();
      final matchSearch = name.contains(_searchQuery.toLowerCase());
      final matchCategory =
          _selectedCategory == 'Semua' ||
          (menu.kategori?.toLowerCase() == _selectedCategory.toLowerCase());
      return matchSearch && matchCategory;
    }).toList();
  }

  bool _hasLevelTopping(BuildContext context) {
    final toppingState = context.read<ToppingBloc>().state;
    if (toppingState is ToppingSuccess) {
      return toppingState.topping.any(
        (t) => (t.kategori ?? '').toLowerCase() == 'level',
      );
    }
    return true;
  }

  void _navigateToDetail(BuildContext context, MenuModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailMenuScreen(menu: item)),
    ).then((_) => setState(() {}));
  }

  void _navigateToEditDetail(
    BuildContext context,
    MenuModel item,
    Map<String, dynamic> cartItem,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetailMenuScreen(menu: item, itemKustomisasiLama: cartItem),
      ),
    ).then((_) => setState(() {}));
  }

  void _onTapAddDirectly(BuildContext context, MenuModel item) {
    final String menuId = item.id.toString();
    final int menuHarga = item.harga is int
        ? item.harga
        : int.tryParse(item.harga.toString()) ?? 0;

    final String uniqueCartItemId = '${menuId}_default';

    context.read<CartBloc>().add(
      AddToCart({
        'order_item_id': uniqueCartItemId,
        'id': menuId,
        'nama': item.nama_menu ?? 'Menu',
        'harga': menuHarga,
        'image_url':item.image_url ?? '',
        'qty': 1,
        'level': '',
        'toppings': [],
        'notes': '',
      }),
    );
  }

  List<Map<String, dynamic>> _getCartItemsByMenuId(
    List<Map<String, dynamic>> cartItems,
    String menuId,
  ) {
    return cartItems.where((item) => item['id'].toString() == menuId).toList();
  }

  void _showVariasiBottomSheet(
    BuildContext context,
    MenuModel item,
    List<Map<String, dynamic>> menuCartItems,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                List<Map<String, dynamic>> currentCart = [];
                if (cartState is CartLoaded) currentCart = cartState.cartItems;

                final activeItems = _getCartItemsByMenuId(
                  currentCart,
                  item.id.toString(),
                );

                if (activeItems.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Navigator.pop(context),
                  );
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        (item.nama_menu ?? '').toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Divider(thickness: 1, color: Color(0xFFF0F0F0)),

                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: activeItems.length,
                          itemBuilder: (context, index) {
                            final cartItem = activeItems[index];
                            final String cItemId = cartItem['order_item_id']
                                .toString();

                            String labelVariasi = cartItem['catatan']
                                .toString()
                                .split('|')
                                .first
                                .trim();
                            if (labelVariasi.isEmpty)
                              labelVariasi = "Varian Standar";

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          labelVariasi,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${_formatPrice(cartItem['harga'])}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _navigateToEditDetail(
                                        context,
                                        item,
                                        cartItem,
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                    label: const Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 2,
                                      ),
                                      visualDensity: VisualDensity.compact,
                                      side: BorderSide(
                                        color: Colors.grey[300]!,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => context
                                            .read<CartBloc>()
                                            .add(DecrementCartItem(cItemId)),
                                        child: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.orange,
                                          size: 22,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        child: Text(
                                          '${cartItem['qty']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => context
                                            .read<CartBloc>()
                                            .add(IncrementCartItem(cItemId)),
                                        child: const Icon(
                                          Icons.add_circle,
                                          color: AppColors.orange,
                                          size: 22,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),
                      const Divider(thickness: 1, color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _navigateToDetail(context, item);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Tambah custom-an lain',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Mau makan apa hari ini?', style: AppTextStyles.judul),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.orange),
            onPressed: () => context.read<MenuBloc>().add(FetchMenu()),
          ),
        ],
      ),
      floatingActionButton: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoaded && state.cartItems.isNotEmpty) {
            final totalQty = state.cartItems.fold(0, (sum, item) => sum + (item['qty'] as int));
            return FloatingActionButton(
              backgroundColor: AppColors.orange,
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.white),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text('$totalQty', style: const TextStyle(fontSize: 9, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, menuState) {
          if (menuState is MenuLoading) {
            return const AppLoadingWidget(message: 'Memuat data menu...');
          }
          List<MenuModel> currentMenu =(menuState is MenuSuccess) ? menuState.menu : [];
          final filteredList = _getFilteredMenus(currentMenu);

          return BlocBuilder<CartBloc, CartState>(
            builder: (context, cartState) {
              final globalCartItems = (cartState is CartLoaded) ? cartState.cartItems : <Map<String, dynamic>>[];

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomSearchBar(
                      controller: _searchController,
                      hintText: 'Cari burger favoritmu...',
                      onChanged: (val) => setState(() {}),
                      onClear: () { _searchController.clear(); setState(() {}); },
                    ),
                  ),
                  const SizedBox(height: 12),
                  KategoriFilter(
                    categories: _categories,
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) => setState(() => _selectedCategory = cat),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filteredList.isEmpty
                    ? const EmptyStateWidget(
                        icon: Icons.fastfood_rounded,
                        title: 'Menu Tidak Ditemukan',
                        description:
                            'Yah, menu tidak ada. Coba cari yang lain ya!',
                      )
                    : _buildUserGridView(
                        filteredList,
                        globalCartItems,menuState
                      ),
                    )
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserGridView(List<MenuModel> filteredMenus,List<Map<String, dynamic>> cartItems, MenuState state) {
    final bool hasReachedMax = (state is MenuSuccess) ? state.hasReachedMax : false;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.74,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: hasReachedMax ? filteredMenus.length : filteredMenus.length + 1,
      itemBuilder: (context, index) {
        if(index>= filteredMenus.length){
          return const Center(child: CircularProgressIndicator(color: AppColors.orange,));
        }
        final item = filteredMenus[index];
        final String menuId = item.id.toString();
        final bool isAvailable = item.tersedia ?? true;
        final String menuKategori = (item.kategori ?? '').toLowerCase();

        final List<Map<String, dynamic>> menuCartItems = _getCartItemsByMenuId(
          cartItems,
          menuId,
        );
        final int currentQty = menuCartItems.fold(
          0,
          (sum, e) => sum + (e['qty'] as int),
        );

        return MenuCard(
          item: item,
          menuId: menuId,
          isAvailable: isAvailable,
          currentQty: currentQty,
          onTapCard: () => _navigateToDetail(context, item),
          onTapAction: () {
            if (currentQty > 0) {
              _showVariasiBottomSheet(context, item, menuCartItems);
            } else {
              if (menuKategori == 'makanan' || _hasLevelTopping(context)) {
                _navigateToDetail(context, item);
              } else {
                _onTapAddDirectly(context, item);
              }
            }
          },
          formatPrice: _formatPrice,
        );
      },
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}
