import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moburger/bloc/topping/topping_bloc.dart';
import 'package:moburger/bloc/topping/topping_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormToppingScreens extends StatefulWidget {
  final dynamic topping;
  const FormToppingScreens({super.key, this.topping});

  @override
  State<FormToppingScreens> createState() => _FormToppingScreensState();
}

class _FormToppingScreensState extends State<FormToppingScreens> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaToppingController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  String? _oldImageUrl;

  String? _selectedKategori;
  String? _selectedTersedia;

  final List<String> _categories = ['level', 'drink', 'topping'];
  final List<String> _statusKetersediaan = ['Tersedia', 'Habis'];

  @override
  void initState() {
    super.initState();
    if (widget.topping != null) {
      _namaToppingController.text = widget.topping.nama_topping ?? '';
      _hargaController.text = widget.topping.harga?.toString() ?? '';
      _selectedKategori = widget.topping.kategori;
      _oldImageUrl = widget.topping.image_url;
      if (widget.topping.tersedia != null) {
        _selectedTersedia = widget.topping.tersedia == true ? 'Tersedia' : 'Habis';
      } else {
        _selectedTersedia = 'Tersedia';
      }
    }
  }

  @override
  void dispose() {
    _namaToppingController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _saveTopping() async {
    if (!_formKey.currentState!.validate()) return;

    final String namaInput = _namaToppingController.text.trim();
    final String namaInputLower = namaInput.toLowerCase();

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppColors.orange),
        ),
      );

      // Pengecekan Duplikat
      final response = await _supabase
          .from('topping')
          .select('id, nama_topping');

      bool isDuplicate = false;
      if (response != null && (response as List).isNotEmpty) {
        for (var item in response) {
          String dbName = (item['nama_topping'] as String).trim().toLowerCase();
          if (dbName == namaInputLower) {
            if (widget.topping != null && item['id'] == widget.topping.id) {
              continue;
            }
            isDuplicate = true;
            break;
          }
        }
      }

      if (isDuplicate) {
        if (mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nama "$namaInput" sudah terdaftar. Gunakan nama topping lain!',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'TUTUP',
              textColor: Colors.white,
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
        return;
      }

      final Map<String, dynamic> toppingData = {
        'nama_topping': namaInput,
        'harga': int.parse(_hargaController.text.trim()),
        'kategori': _selectedKategori,
        'tersedia': _selectedTersedia == 'Tersedia',
      };

      if (widget.topping == null) {
        context.read<ToppingBloc>().add(CreateTopping(toppingData));
      } else {
        context.read<ToppingBloc>().add(UpdateTopping(widget.topping.id, toppingData));
      }

      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.topping == null ? 'Tambah Topping Baru' : 'Edit Topping Produk',
          style: AppTextStyles.judul,
        ),
        backgroundColor: AppColors.darkRed,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text('Nama Topping', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _namaToppingController,
                hintText: "Nama Produk",
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nama topping tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Harga Produk (Rp)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _hargaController,
                hintText: "contoh: 35000",
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harga produk tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Kategori Topping', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedKategori = val),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null ? 'Pilih salah satu kategori' : null,
              ),
              const SizedBox(height: 16),
              const Text('Status Ketersediaan', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTersedia,
                items: _statusKetersediaan.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (val) => setState(() => _selectedTersedia = val),
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null ? 'Pilih status ketersediaan produk' : null,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: "Batal",
                      backgroundColor: Colors.grey[200]!,
                      textColor: AppColors.black,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: widget.topping == null ? 'Tambah Topping' : 'Simpan Perubahan',
                      onPressed: _saveTopping,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}