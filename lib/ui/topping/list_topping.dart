import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/topping/topping_bloc.dart';
import 'package:moburger/bloc/topping/topping_event.dart';
import 'package:moburger/bloc/topping/topping_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/widget/custom_search.dart';
import 'package:moburger/core/widget/custom_alert_dialog.dart';
import 'package:moburger/core/widget/custom_status_card.dart';
import 'package:moburger/core/widget/empty_state_widget.dart';
import 'package:moburger/core/widget/kategori_filter.dart';
import 'package:moburger/data/models/topping_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ToppingPage extends StatefulWidget {
  const ToppingPage({super.key});

  @override
  State<ToppingPage> createState() => _ToppingPageState();
}

class _ToppingPageState extends State<ToppingPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = ['Semua', 'level', 'topping', 'drink'];

  @override
  void initState() {
    super.initState();
    context.read<ToppingBloc>().add(FetchTopping());
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleAvailability(dynamic id, bool currentValue) async {
    try {
      await _supabase
          .from('topping')
          .update({'tersedia': !currentValue})
          .eq('id', id);

      if (mounted) {
        context.read<ToppingBloc>().add(FetchTopping());
        _showSnackBar(!currentValue ? 'Topping ditandai tersedia' : 'Topping ditandai habis');
      }
    } catch (e) {
      _showSnackBar('Gagal mengubah ketersediaan: $e', isError: true);
    }
  }

  void _deleteTopping(dynamic id) async {
    final confirm = await CustomAlertDialog.showDeleteDialog(
      context: context,
      title: 'Hapus Topping',
      content: 'Yakin ingin menghapus topping ini? Tindakan tidak dapat dibatalkan.',
    );
    if (confirm != true) return;

    try {
      await _supabase.from('topping').delete().eq('id', id);
      if (mounted) {
        context.read<ToppingBloc>().add(FetchTopping());
        _showSnackBar('Topping berhasil dihapus');
      }
    } catch (e) {
      _showSnackBar('Gagal menghapus topping: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  List<ToppingModel> _getFilteredToppings(List<ToppingModel> toppingList) {
    return toppingList.where((topping) {
      final name = (topping.nama_topping ?? '').toLowerCase();
      final matchSearch = name.contains(_searchQuery.toLowerCase());
      final matchCategory = _selectedCategory == 'Semua' || 
          (topping.kategori?.toLowerCase() == _selectedCategory.toLowerCase());
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
        title: const Text(
          'Manajemen Topping',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.orange),
            onPressed: () => context.read<ToppingBloc>().add(FetchTopping()),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<ToppingBloc, ToppingState>(
        listener: (context, state) {
          if (state is ToppingCreateSuccess || state.runtimeType.toString().contains('UpdateSuccess')) {
            context.read<ToppingBloc>().add(FetchTopping());
          }
          if (state is ToppingError) {
            _showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ToppingLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.orange));
          }
          List<ToppingModel> currentToppings = [];
          if (state is ToppingSuccess) {
            currentToppings = state.topping;
          }
          final filteredList = _getFilteredToppings(currentToppings);
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ToppingBloc>().add(FetchTopping());
            },
            color: AppColors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAdminDashboard(currentToppings),
                const SizedBox(height: 12),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CustomSearchBar(
                    controller: _searchController,
                    hintText: 'Cari topping...',
                    onChanged: (val) => setState(() {}),
                    onClear: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(height: 12),

                KategoriFilter(
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onSelected: (category) => setState(() => _selectedCategory = category),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: filteredList.isEmpty
                      ? const EmptyStateWidget(
                          icon: Icons.search_off_rounded,
                          title: 'Topping Tidak Ditemukan',
                          description: 'Ganti kata kunci pencarian atau tambah item topping baru.',
                        )
                      : _buildToppingListView(filteredList),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          heroTag: 'fab_topping_add', 
          onPressed: () => _showFormDialog(context),
          backgroundColor: AppColors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: const Icon(Icons.add_rounded, color: AppColors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildAdminDashboard(List<ToppingModel> toppingList) {
    int total = toppingList.length;
    int active = toppingList.where((t) => t.tersedia == true).length;
    int level = toppingList.where((t) => t.kategori == 'level').length;
    int topping = toppingList.where((t) => t.kategori == 'topping').length;
    int drink = toppingList.where((t) => t.kategori == 'drink').length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _buildStatItem('Total', '$total', Icons.layers_rounded, AppColors.orange),
          _buildStatItem('Aktif', '$active', Icons.check_circle_outline_rounded, AppColors.success),
          _buildStatItem('Level', '$level', Icons.local_fire_department_rounded, AppColors.error),
          _buildStatItem('Topping', '$topping', Icons.celebration, AppColors.yellow),
          _buildStatItem('Drink', '$drink', Icons.water_drop_rounded, AppColors.info),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return FractionallySizedBox(
      widthFactor: 0.305, // Menjamin 3 kartu per baris
      child:      OptionCard(
        label: label,
        value: value,
        icon: icon,
        color: color,
      ),
    );
  }

  Widget _buildToppingListView(List<ToppingModel> toppings) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: toppings.length,
      itemBuilder: (context, index) {
        final item = toppings[index];
        final bool isAvailable = item.tersedia ?? true;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.darkRed.withOpacity(0.05), width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Opacity(
              opacity: isAvailable ? 1.0 : 0.6,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getColorByKategori(item.kategori).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getIconByKategori(item.kategori), color: _getColorByKategori(item.kategori), size: 22),
                ),
                title: Text(
                  item.nama_topping ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      (item.kategori ?? '').toUpperCase() == 'LEVEL' ? 'Gratis / Kustom' : 'Rp ${_formatPrice(item.harga)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: (item.kategori ?? '').toLowerCase() == 'level' ? AppColors.textSecondary : AppColors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showFormDialog(context, topping: item);
                        } else if (value == 'delete') {
                          _deleteTopping(item.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, color: AppColors.info, size: 18),
                              SizedBox(width: 10),
                              Text('Edit Topping', style: TextStyle(color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, color: AppColors.error, size: 18),
                              SizedBox(width: 10),
                              Text('Hapus Topping', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFormDialog(BuildContext context, {ToppingModel? topping}) {
    final nameController = TextEditingController(text: topping?.nama_topping);
    final priceController = TextEditingController(text: topping?.harga?.toString());
    
    String currentDialogCategory = topping?.kategori ?? 'topping';
    bool currentDialogAvailable = topping?.tersedia ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                topping == null ? 'Tambah Topping Baru' : 'Edit Data Topping',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Nama Topping',
                        labelStyle: const TextStyle(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)',
                        labelStyle: const TextStyle(fontSize: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: 'Contoh: 5000',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Kategori Topping', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(8)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentDialogCategory,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'level', child: Text('level (Pedas Makanan)')),
                            DropdownMenuItem(value: 'topping', child: Text('topping (Ekstra Makanan)')),
                            DropdownMenuItem(value: 'drink', child: Text('drink (Ekstra Minuman)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() => currentDialogCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.trim().isEmpty) return;

                    final payload = {
                      'nama_topping': nameController.text.trim(),
                      'harga': int.tryParse(priceController.text.trim()) ?? 0,
                      'kategori': currentDialogCategory,
                      'tersedia': currentDialogAvailable,
                    };

                    if (topping == null) {
                      context.read<ToppingBloc>().add(CreateTopping(payload));
                    } else {
                      context.read<ToppingBloc>().add(UpdateTopping(topping.id!, payload));
                    }
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getIconByKategori(String? kategori) {
    switch (kategori?.toLowerCase()) {
      case 'level':
        return Icons.local_fire_department_rounded;
      case 'drink':
        return Icons.water_drop_rounded;
      default:
        return Icons.lunch_dining_rounded;
    }
  }

  Color _getColorByKategori(String? kategori) {
    switch (kategori?.toLowerCase()) {
      case 'level':
        return AppColors.error;
      case 'drink':
        return AppColors.info;
      default:
        return AppColors.orange;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    return price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}