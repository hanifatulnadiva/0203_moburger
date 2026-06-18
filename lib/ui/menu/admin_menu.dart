import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/bloc/menu/menu_event.dart';
import 'package:moburger/bloc/menu/menu_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_search.dart';
import 'package:moburger/core/widget/custom_alert_dialog.dart';
import 'package:moburger/core/widget/custom_status_card.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/core/widget/kategori_filter.dart';
import 'package:moburger/core/widget/loading_widget.dart';
import 'package:moburger/data/models/menu_model.dart';
import 'package:moburger/ui/menu/form_menu.dart';
import 'package:moburger/ui/menu/detail_menu.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';


  final List<String> _categories = ['Semua', 'makanan', 'minuman', 'snack'];
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchMenu());
    _scrollController.addListener(_onScroll); // Tambahkan ini
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }
  void _onScroll() {
    // Jika mendekati bawah (200px), panggil LoadMoreMenu
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<MenuBloc>().add(LoadMoreMenu());
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll); // Hapus listener
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleAvailability(String id, bool currentValue) async {
    context.read<MenuBloc>().add(UpdateMenuStatus(id, !currentValue));
    try {
      await _supabase
          .from('menu')
          .update({'tersedia': !currentValue})
          .eq('id', id);
    } catch (e) {
      context.read<MenuBloc>().add(UpdateMenuStatus(id, currentValue));
      _showSnackBar('Gagal mengubah status: $e', isError: true);
    }
  }

  Future<void> _deleteMenu(dynamic id) async {
    final confirm = await CustomAlertDialog.showDeleteDialog(
      context: context,
      title: 'Hapus Menu',
      content: 'Yakin ingin menghapus menu ini? Tindakan tidak dapat dibatalkan.',
    );
    if (confirm != true) return;

    try {
      await _supabase.from('menu').delete().eq('id', id);
      if (mounted) {
        context.read<MenuBloc>().add(FetchMenu());
        _showSnackBar('Menu berhasil deleted');
      }
    } catch (e) {
      _showSnackBar('Gagal menghapus menu: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? AppColors.error : AppColors.success, behavior: SnackBarBehavior.floating),
    );
  }

  List<MenuModel> _getFilteredMenus(List<MenuModel> menuList) {
    return menuList.where((menu) {
      final name = (menu.nama_menu ?? '').toLowerCase();
      final matchSearch = name.contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' || 
          (menu.kategori?.toLowerCase() == _selectedCategory.toLowerCase());
      return matchSearch && matchCategory;
    }).toList();
  }

  Widget _buildAdminDashboard(List<MenuModel> menuList) {
    int total = menuList.length;
    int available = menuList.where((m) => m.tersedia == true).length;
    int habis = menuList.where((m) => m.tersedia == false).length;
    int makanan = menuList.where((m) => m.kategori?.toLowerCase() == 'makanan').length;
    int minuman = menuList.where((m) => m.kategori?.toLowerCase() == 'minuman').length;
    int snack= menuList.where((m) => m.kategori?.toLowerCase() == 'snack').length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatItem('Total', '$total', Icons.restaurant_menu, AppColors.orange),
          _buildStatItem('Tersedia', '$available', Icons.check_circle_outline_rounded, AppColors.success),
          _buildStatItem('Hanis', '$habis', Icons.check_circle_outline_rounded, AppColors.darkRed),
          _buildStatItem('Makanan', '$makanan', Icons.lunch_dining_rounded, AppColors.yellow),
          _buildStatItem('Minuman', '$minuman', Icons.local_drink_rounded, AppColors.info),
          _buildStatItem('Snack', '$snack', Icons.cookie, AppColors.warning),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return FractionallySizedBox(
      widthFactor: 0.305, // Membuat 3 kartu per baris
      child: OptionCard(
        label: label,
        value: value,
        icon: icon,
        color: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Manajemen Menu (Admin)', style: AppTextStyles.judul),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded, color: AppColors.orange), onPressed: () => context.read<MenuBloc>().add(FetchMenu())),
        ],
      ),
      body: BlocConsumer<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state is MenuCreateSuccess) context.read<MenuBloc>().add(FetchMenu());
          if (state is MenuError) _showSnackBar(state.message, isError: true);
        },
        builder: (context, state) {
          if (state is MenuLoading) return const AppLoadingWidget(message: 'Memuat data menu...');
          List<MenuModel> currentMenu = [];
          if (state is MenuSuccess) currentMenu = state.menu;
          final filteredList = _getFilteredMenus(currentMenu);

          return RefreshIndicator(
            onRefresh: () async => context.read<MenuBloc>().add(FetchMenu()),
            color: AppColors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdminDashboard(currentMenu),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Cari menu stok...',
                    onChanged: (val) => setState(() {}),
                    onClear: () { _searchController.clear(); setState(() {}); },
                  ),
                ),
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
                const SizedBox(height: 12),
                Expanded(
                  child: filteredList.isEmpty
                      ? const EmptyStateWidget(icon: Icons.search_off_rounded, title: 'Menu Tidak Ditemukan', description: 'Ganti kata kunci atau tambah menu baru.')
                      : _buildAdminListView(filteredList),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 100.0),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<MenuBloc>(), child: const FormMenuScreens())));
            if (context.mounted) context.read<MenuBloc>().add(FetchMenu());
          },
          backgroundColor: AppColors.orange,
          child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildAdminListView(List<MenuModel> filteredMenus) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filteredMenus.length+1,
      itemBuilder: (context, index) {
        if (index == filteredMenus.length) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(color: AppColors.orange),
          ),
        );
      }
        final item = filteredMenus[index];
        final bool isAvailable = item.tersedia;
        return Card(
          margin: const EdgeInsets.only(bottom: 12), color: AppColors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.darkRed.withOpacity(0.05))),
          child: ListTile(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailMenuScreen(menu: item))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: Hero(tag: 'menu_image_${item.id}', child: _buildMenuThumbnail(item.image_url, item.kategori)),
            title: Text(item.nama_menu ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Rp ${_formatPrice(item.harga)}', style: const TextStyle(color: AppColors.orange, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: isAvailable ? AppColors.success.withOpacity(0.12) : AppColors.error.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(isAvailable ? 'Tersedia' : 'Habis', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isAvailable ? AppColors.success : AppColors.error)),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: isAvailable,
                  activeTrackColor: AppColors.success.withOpacity(0.5),
                  activeColor: AppColors.success,
                  onChanged: (val) => _toggleAvailability(item.id.toString(), isAvailable),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'edit') {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => BlocProvider.value(value: context.read<MenuBloc>(), child: FormMenuScreens(menu: item))));
                      if (context.mounted) context.read<MenuBloc>().add(FetchMenu());
                    } else if (value == 'delete') {
                      _deleteMenu(item.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, color: AppColors.info, size: 18), SizedBox(width: 10), Text('Edit Menu')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_rounded, color: AppColors.error, size: 18), SizedBox(width: 10), Text('Hapus Menu', style: TextStyle(color: AppColors.error))])),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuThumbnail(String? imageUrl, String? category) {
    IconData icon = category?.toLowerCase() == 'minuman' ? Icons.local_drink_rounded : Icons.lunch_dining_rounded;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(icon, color: AppColors.orange)));
    }
    return Icon(icon, color: AppColors.orange);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}