import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_search.dart';
import 'package:moburger/core/widget/custom_alert_dialog.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
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

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(FetchMenu());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleAvailability(String id, bool currentValue) async {
    // 1. Optimistic Update (Local UI)
    // Anda tidak perlu setState manual jika sudah memakai BlocConsumer yang benar
    
    // 2. Kirim event ke Bloc untuk update lokal + update ke Supabase
    context.read<MenuBloc>().add(UpdateMenuStatus(id, !currentValue));
    
    try {
      await _supabase
          .from('menu')
          .update({'tersedia': !currentValue})
          .eq('id', id);
    } catch (e) {
      // Jika gagal, rollback ke status sebelumnya
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
                _buildCategoryChips(),
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(category), selected: isSelected, showCheckmark: false,
              onSelected: (selected) { if (selected) setState(() => _selectedCategory = category); },
              selectedColor: AppColors.orange, backgroundColor: AppColors.white,
              labelStyle: TextStyle(color: isSelected ? AppColors.white : AppColors.textSecondary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? AppColors.orange : AppColors.textSecondary.withOpacity(0.2))),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminDashboard(List<MenuModel> menuList) {
    int countByCategory(String category) => category == 'Semua' ? menuList.length : menuList.where((m) => m.kategori?.toLowerCase() == category.toLowerCase()).length;
    int countAvailable() => menuList.where((m) => m.tersedia == true).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatCard('Total Menu', countByCategory('Semua'), Icons.restaurant_menu, AppColors.orange),
            const SizedBox(width: 12),
            _buildStatCard('Tersedia', countAvailable(), Icons.check_circle_outline_rounded, AppColors.success),
            const SizedBox(width: 12),
            _buildStatCard('Makanan', countByCategory('makanan'), Icons.lunch_dining_rounded, AppColors.yellow),
            const SizedBox(width: 12),
            _buildStatCard('Minuman', countByCategory('minuman'), Icons.local_drink_rounded, AppColors.info),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon, Color color) {
    return Container(
      width: 120, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.15))),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 8),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, 
            children: [Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis), Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]))
        ],
      ),
    );
  }

  Widget _buildAdminListView(List<MenuModel> filteredMenus) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: filteredMenus.length,
      itemBuilder: (context, index) {
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
                  inactiveTrackColor: AppColors.textSecondary.withOpacity(0.2),
                  inactiveThumbColor: AppColors.textSecondary.withOpacity(0.5),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // [Fix]: Oper id asli tanpa string casting paksa agar tipe data di database match
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