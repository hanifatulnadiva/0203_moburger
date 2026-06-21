import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/bloc/menu/menu_event.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/core/contants/text.dart';
import 'package:moburger/core/widget/custom_button.dart';
import 'package:moburger/core/widget/custom_textfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FormMenuScreens extends StatefulWidget {
  final dynamic menu; 
  const FormMenuScreens({super.key, this.menu});

  @override
  State<FormMenuScreens> createState() => _FormMenuScreensState();
}

class _FormMenuScreensState extends State<FormMenuScreens> {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaMenuController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage; 
  String? _oldImageUrl;
  String? _selectedKategori;
  String? _selectedTersedia;
  final List<String> _categories = ['makanan', 'minuman', 'snack'];
  final List<String> _statusKetersediaan = ['Tersedia', 'Habis'];

  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      _namaMenuController.text = widget.menu.nama_menu ?? '';
      _hargaController.text = widget.menu.harga?.toString() ?? '';
      _selectedKategori = widget.menu.kategori;
      _oldImageUrl = widget.menu.image_url; 
      _deskripsiController.text = widget.menu.deskripsi?? '';
      if (widget.menu.tersedia != null) {
        _selectedTersedia = widget.menu.tersedia == true ? 'Tersedia' : 'Habis';
      } else {
        _selectedTersedia = 'Tersedia';
      }
    }
  }

  @override
  void dispose() {
    _namaMenuController.dispose();
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
  Future<void> _saveMenu() async {
    if (!_formKey.currentState!.validate()) return;

    final String namaBaru = _namaMenuController.text.trim();

    try {
      // Menampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.orange)),
      );

      // 1. Pengecekan Duplikat (Case-Insensitive)
      // Menggunakan .ilike untuk mendeteksi 'Burger' dan 'burger' sebagai data yang sama
      var query = _supabase
          .from('menu')
          .select('id')
          .ilike('nama_menu', namaBaru);

      // Jika sedang mode Edit, abaikan record milik sendiri agar tidak terdeteksi duplikat
      if (widget.menu != null) {
        query = query.neq('id', widget.menu.id);
      }

      final List<dynamic> response = await query;

      if (response.isNotEmpty) {
        if (mounted) Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menu dengan nama tersebut sudah ada!'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Hentikan proses
      }

      // 2. Validasi Gambar (Hanya untuk menu baru)
      if (widget.menu == null && _selectedImage == null) {
        if (mounted) Navigator.pop(context); // Tutup loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih foto produk terlebih dahulu')),
        );
        return;
      }

      // 3. Proses Upload Gambar
      String? imageUrl = _oldImageUrl;
      if (_selectedImage != null) {
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
        final File fileToUpload = File(_selectedImage!.path);
        
        await _supabase.storage.from('burger_image').upload(
          fileName,
          fileToUpload,
          fileOptions: const FileOptions(contentType: 'image/png'),
        );
        
        imageUrl = _supabase.storage.from('burger_image').getPublicUrl(fileName);
      }

      // 4. Persiapan Data
      final Map<String, dynamic> menuData = {
        'nama_menu': namaBaru,
        'harga': int.parse(_hargaController.text.trim()),
        'kategori': _selectedKategori,
        'tersedia': _selectedTersedia == 'Tersedia',
        'image_url': imageUrl,
        'deskripsi': _deskripsiController.text.trim()
      };

      // 5. Kirim ke Bloc
      if (widget.menu == null) {
        context.read<MenuBloc>().add(CreateMenu(menuData));
      } else {
        context.read<MenuBloc>().add(UpdateMenu(widget.menu.id, menuData));
      }

      if (mounted) {
        Navigator.pop(context); // Tutup loading
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
      
    } catch (e) {
      if (mounted) Navigator.pop(context); // Pastikan loading tertutup jika error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data menu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.menu == null ? 'Tambah Menu Baru' : 'Edit Menu Produk', style:AppTextStyles.judul,),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                        )
                      : (_oldImageUrl != null && _oldImageUrl!.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                _oldImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                ),
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_rounded, size: 48, color: AppColors.orange),
                                  SizedBox(height: 10),
                                  Text('Unggah Foto Produk Burger', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('Nama Menu', style: AppTextStyles.formLabel),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _namaMenuController,
                hintText: "Nama Produk",
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nama menu tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Harga Produk (Rp)', style: AppTextStyles.formLabel),
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

              const Text('Kategori Menu', style:AppTextStyles.formLabel),
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

              const Text('Status Ketersediaan', style: AppTextStyles.formLabel),
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
              const Text('Deskripsi Produk',style: AppTextStyles.formLabel),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _deskripsiController,
                keyboardType: TextInputType.multiline,
                minLines: 4,
                maxLines: 8,
                hintText: 'Masukkan deskripsi produk...',
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
                    text: widget.menu== null? 'Tambah Produk':'Simpan Perubahan',
                    onPressed: _saveMenu,
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