import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/bloc/cart/cart_bloc.dart';
import 'package:moburger/bloc/cart/cart_event.dart';
import 'package:moburger/bloc/topping/topping_bloc.dart';
import 'package:moburger/bloc/topping/topping_event.dart';
import 'package:moburger/bloc/topping/topping_state.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_quantity_selector.dart';
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:moburger/data/models/topping_model.dart';

class DetailMenuScreen extends StatefulWidget {
  final dynamic menu;
  final Map<String, dynamic>? itemKustomisasiLama;

  const DetailMenuScreen({
    super.key,
    required this.menu,
    this.itemKustomisasiLama,
  });

  @override
  State<DetailMenuScreen> createState() => _DetailMenuScreenState();
}

class _DetailMenuScreenState extends State<DetailMenuScreen> {
  int _quantity = 1;
  String _selectedLevel = '';
  bool _levelRequiredButMissing = false;
  final TextEditingController _catatanController = TextEditingController();
  final List<ToppingModel> _selectedToppings = [];

  double _scrollOffset = 0.0;
  final double _imageHeight = 350.0;

  @override
  void initState() {
    super.initState();
    context.read<ToppingBloc>().add(FetchTopping());

    if (widget.itemKustomisasiLama != null) {
      final dataLama = widget.itemKustomisasiLama!;
      _quantity = dataLama['qty'] ?? 1;
      _selectedLevel = dataLama['level'] ?? '';

      final String catatanLama = dataLama['notes']?.toString() ?? '';
      if (catatanLama.contains('| Note:')) {_catatanController.text = catatanLama.split('| Note:').last.trim();
      } else if (!catatanLama.contains('Variasi:') &&
          !catatanLama.contains('Topping:')) {
        _catatanController.text = catatanLama;
      }
    }
  }

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) setState(() => _quantity--);
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  String _formatHarga(dynamic harga) {
    if (harga == null) return '0';
    final int nilai = harga is int
        ? harga
        : int.tryParse(harga.toString()) ?? 0;
    return nilai.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  String _capitalizeEachWord(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  void _simpanKeKeranjang(int hargaSatuanTotal) {
    final String menuId = widget.menu.id.toString();
    print("DEBUG DETAIL - Topping Terpilih: ${_selectedToppings.map((t) => t.id).toList()}");
    final List<String> toppingIds =_selectedToppings.map((t) => t.id ?? '').toList();
    final String toppingKey = toppingIds.isNotEmpty? toppingIds.join(','): 'empty';
    final String levelKey = _selectedLevel.isNotEmpty? _selectedLevel.replaceAll(' ', '').toLowerCase(): 'normal';
    final String uniqueCartItemId = '${menuId}_${levelKey}_$toppingKey';
    final List<String> toppingNames = _selectedToppings.map((t) => t.nama_topping ?? '').toList();

    String rincianVariasi = _selectedLevel.isNotEmpty? 'Variasi: $_selectedLevel': '';
    if (toppingNames.isNotEmpty) {
      rincianVariasi += rincianVariasi.isNotEmpty? ', Topping: ${toppingNames.join(', ')}': 'Topping: ${toppingNames.join(', ')}';
    }

    String catatanAkhir = rincianVariasi;
    if (_catatanController.text.trim().isNotEmpty) {
      catatanAkhir += catatanAkhir.isNotEmpty? ' | Note: ${_catatanController.text.trim()}': _catatanController.text.trim();
    }

    final Map<String, dynamic> dataPayload = {
      'order_item_id': uniqueCartItemId,
      'id': menuId,
      'nama': _capitalizeEachWord(widget.menu.nama_menu ?? 'Hamburger'),
      'harga': hargaSatuanTotal,
      'qty': _quantity,
      'level': _selectedLevel,
      'toppings': toppingIds,
      'notes': catatanAkhir,
      'image_url': widget.menu.image_url ?? '',
    };

    if (widget.itemKustomisasiLama != null) {
      context.read<CartBloc>().add(
        UpdateCartItem(
          oldCartItemId: widget.itemKustomisasiLama!['order_item_id'].toString(),
          newItem: dataPayload,
        ),
      );
    } else {
      context.read<CartBloc>().add(AddToCart(dataPayload));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text(
          widget.itemKustomisasiLama != null
              ? 'Variasi menu berhasil diperbarui!'
              : 'Sukses dimasukkan ke keranjang! (${_quantity}x)',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl = widget.menu.image_url ?? '';
    final String menuKategori = widget.menu.kategori.toString().toLowerCase();
    final int hargaDasarMenu = widget.menu.harga is int
        ? widget.menu.harga
        : int.tryParse(widget.menu.harga.toString()) ?? 0;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    final double imageTopPosition = _scrollOffset > 0 ? -_scrollOffset : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: BlocBuilder<ToppingBloc, ToppingState>(
        builder: (context, state) {
          final int hargaToppingTotal = _selectedToppings.fold(
            0,
            (sum, t) => sum + (t.harga ?? 0),
          );
          final int hargaSatuanTotal = hargaDasarMenu + hargaToppingTotal;
          return _buildBottomBar(hargaSatuanTotal);
        },
      ),
      body: Stack(
        children: [
          Positioned(
            top: imageTopPosition,
            left: 0,
            right: 0,
            height: _imageHeight,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                color: Colors.white.withValues(
                  alpha: 0.08,
                ), 
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isNotEmpty
                      ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) =>
                          const Center(
                            child: Icon(
                              Icons.fastfood_rounded,
                              size: 80,
                              color: AppColors.orange,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.darkRed,
                          child: const Icon(Icons.fastfood_rounded,size: 100,color: AppColors.orange,),
                        ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                setState(() => _scrollOffset = notification.metrics.pixels);
                return true;
              },
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: _imageHeight),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24.0,28,24,24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  _capitalizeEachWord(
                                    widget.menu.nama_menu ?? 'Hamburger',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'Rp ${_formatHarga(widget.menu.harga)}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            menuKategori.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.menu.deskripsi ??
                                'Tidak ada deskripsi untuk menu ini.',
                            style: AppTextStyles.bodyRegular
                          ),
                          BlocBuilder<ToppingBloc, ToppingState>(
                            builder: (context, state) {
                              if (state is ToppingLoading) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.orange,
                                    ),
                                  ),
                                );
                              }

                              if (state is ToppingSuccess) {
                                final allToppings = state.topping;
                                final levelToppings = allToppings
                                    .where((t) =>(t.kategori ?? '').toLowerCase() =='level',).toList();
                                final extraToppings = allToppings
                                    .where((t) =>(t.kategori ?? '').toLowerCase() =='topping',).toList();
                                final drinkToppings = allToppings
                                    .where((t) =>(t.kategori ?? '').toLowerCase() =='drink',).toList();

                                final bool levelWajibBelumDipilih =
                                    menuKategori == 'makanan' &&
                                    levelToppings.isNotEmpty &&
                                    _selectedLevel.isEmpty;
                                if (_levelRequiredButMissing != levelWajibBelumDipilih) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _levelRequiredButMissing = levelWajibBelumDipilih;
                                      });
                                    }
                                  });
                                }

                                if (widget.itemKustomisasiLama != null &&
                                    _selectedToppings.isEmpty) {
                                  final List<dynamic> namaToppingsLama =
                                      widget.itemKustomisasiLama!['toppings'] ??
                                      [];
                                  for (var nama in namaToppingsLama) {
                                    for (var topping in allToppings) {
                                      if (topping.nama_topping == nama) {
                                        if (!_selectedToppings.any(
                                          (t) => t.id == topping.id,
                                        )) {
                                          _selectedToppings.add(topping);
                                        }
                                      }
                                    }
                                  }
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (menuKategori != 'minuman') ...[
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.0,
                                        ),
                                        child: Divider(
                                          color: Color(0xFFE8D5C8),
                                          thickness: 1,
                                        ),
                                      ),
                                      if (menuKategori == 'makanan' && levelToppings.isNotEmpty) ...[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('PILIH LEVEL', style: AppTextStyles.formLabel),
                                            Text(
                                              'Wajib',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        _buildLevelOptions(levelToppings),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 14.0,),
                                          child: Divider(
                                            color: Color(0xFFE8D5C8),
                                            thickness: 1,
                                          ),
                                        ),
                                      ],
                                      if (menuKategori == 'makanan' &&extraToppings.isNotEmpty) ...[
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('TOPPING',style: AppTextStyles.formLabel),
                                            Text(
                                              'Opsional',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        _buildToppingOptions(extraToppings),
                                        if (drinkToppings.isNotEmpty)
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 14.0,
                                            ),
                                            child: Divider(
                                              color: Color(0xFFE8D5C8),
                                              thickness: 1,
                                            ),
                                          ),
                                      ],
                                      if ((menuKategori == 'makanan' || menuKategori == 'snack') &&drinkToppings.isNotEmpty) ...[
                                        Row(
                                          mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('PILIH MINUMAN',style: AppTextStyles.formLabel),
                                            Text(
                                              'Opsional',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        _buildToppingOptions(drinkToppings),
                                      ],
                                    ],
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 14.0,),
                                      child: Divider(
                                        color: Color(0xFFE8D5C8),
                                        thickness: 1,
                                      ),
                                    ),
                                    const Text('CATATAN PESANAN',style: AppTextStyles.formLabel),
                                    const SizedBox(height: 10),
                                    CustomTextField(
                                      controller: _catatanController,
                                      keyboardType: TextInputType.name,
                                      minLines: 3,
                                      maxLines: 4,
                                      hintText:
                                      'Catatan',
                                    ),
                                  ],
                                );
                              }

                              if (state is ToppingError) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12.0,),
                                  child: Text(
                                    'Gagal memuat opsi variasi: ${state.message}',
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: CircleAvatar(
              backgroundColor: AppColors.orange.withValues(alpha: 0.7),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(int hargaSatuanTotal) {
    return Container(
      padding: EdgeInsets.fromLTRB(24,16,24,MediaQuery.of(context).padding.bottom + 16,),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_levelRequiredButMissing)
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Silakan pilih level terlebih dahulu',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          Row(
            children: [
              CustomQuantitySelector(
                quantity: _quantity,
                onIncrement: _increment,
                onDecrement: _decrement,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  text:'Tambah  •  Rp ${_formatHarga(hargaSatuanTotal * _quantity)}',
                  icon: widget.itemKustomisasiLama != null
                    ? Icons.check_circle_outline
                    : Icons.shopping_cart_outlined,
                  borderRadius: 25,
                  backgroundColor: AppColors.darkRed,
                  textColor: Colors.white,
                  onPressed: ((widget.menu.tersedia ?? true) && !_levelRequiredButMissing)
                    ? () => _simpanKeKeranjang(hargaSatuanTotal)
                    : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelOptions(List<ToppingModel> levels) {
    return Column(
      children: levels.map((level) {
        final String namaLevel = level.nama_topping ?? 'Level';
        return RadioListTile<String>(
          title: Text(namaLevel,style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          value: namaLevel,
          groupValue: _selectedLevel,
          activeColor: AppColors.orange,
          contentPadding: EdgeInsets.zero,
          dense: true,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedLevel = value;
                _levelRequiredButMissing = false;
              });
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildToppingOptions(List<ToppingModel> toppings) {
    return Column(
      children: toppings.map((topping) {
        final String toppingId = topping.id ?? '';
        final String namaTopping = topping.nama_topping ?? 'Topping';
        final int harga = topping.harga ?? 0;
        final bool isAvailable = topping.tersedia ?? true;
        final bool isSelected = _selectedToppings.any((t) => t.id == toppingId);

        return CheckboxListTile(
          title: Text(
            namaTopping,
            style: TextStyle(
              fontSize: 14,
              color: isAvailable ? AppColors.textPrimary : Colors.grey[400],
              decoration: isAvailable
                  ? TextDecoration.none
                  : TextDecoration.lineThrough,
            ),
          ),
          secondary: Text(
            isAvailable ? '+ Rp ${_formatHarga(harga)}' : 'Habis',
            style: TextStyle(
              fontSize: 13,
              color: isAvailable ? AppColors.orange : Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          value: isSelected,
          activeColor: AppColors.orange,
          contentPadding: EdgeInsets.zero,
          dense: true,
          onChanged: isAvailable
              ? (bool? checked) {
                  setState(() {
                    if (checked == true) {
                      if (!_selectedToppings.any((t) => t.id == toppingId)) {
                        _selectedToppings.add(topping);
                      }
                    } else {
                      _selectedToppings.removeWhere((t) => t.id == toppingId);
                    }
                  });
                  print("DEBUG - Topping Dipilih Saat Ini: ${_selectedToppings.map((t) => t.id).toList()}");
                }
              : null,
        );
      }).toList(),
    );
  }
}