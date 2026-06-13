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
  final TextEditingController _deskripsiController = TextEditingController();

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
      _deskripsiController.text = widget.topping.toString() ?? '';
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
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text('Kamera', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.white),
                  title: const Text('Pilih dari Galeri', style: TextStyle(color: Colors.white)),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: 50, 
        maxWidth: 800,    
      );
      if (photo != null) {
        setState(() {
          _selectedImage = photo; 
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }
  void _saveTopping() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );
      final Map<String, dynamic> toppingData = {
        'nama_topping': _namaToppingController.text.trim(),
        'harga': int.parse(_hargaController.text.trim()),
        'kategori': _selectedKategori,
        'tersedia': _selectedTersedia == 'Tersedia',
      };

      if (mounted) Navigator.pop(context);
      if (widget.topping == null) {
        context.read<ToppingBloc>().add(CreateTopping(toppingData)); 
      } else {
        context.read<ToppingBloc>().add(UpdateTopping(widget.topping.id, toppingData)); 
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data topping: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.topping == null ? 'Tambah Topping Baru' : 'Edit Topping Produk', style: AppTextStyles.judul,),
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
              SizedBox(height: 8),
              CustomTextField(
                controller:_hargaController,
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
              const Text('Deskripsi Produk',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 32),

              Row(children: [
                Expanded(
                  child: PrimaryButton(
                    text:"Batal",
                    backgroundColor: Colors.grey[200]!,
                    textColor: AppColors.black,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: PrimaryButton(
                    text: widget.topping== null? 'Tambah Produk':'Simpan Perubahan',
                    onPressed: _saveTopping,
                  )
                )
              ],)
            ],
          ),
        ),
      ),
    );
  }
}