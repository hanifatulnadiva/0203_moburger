import 'package:flutter/material.dart';
import 'package:moburger/core/contants/colors.dart';
import 'package:moburger/data/models/menu_model.dart';

class MenuCard extends StatelessWidget {
  final MenuModel item;
  final String menuId;
  final bool isAvailable;
  final int currentQty;
  final VoidCallback onTapCard;
  final VoidCallback onTapAction;
  final String Function(dynamic) formatPrice;

  const MenuCard({
    super.key,
    required this.item,
    required this.menuId,
    required this.isAvailable,
    required this.currentQty,
    required this.onTapCard,
    required this.onTapAction,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    print("DEBUG MENU: Nama=${item.nama_menu}, Deskripsi=${item.deskripsi}");
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BAGIAN GAMBAR (Dibuat Expanded agar mengisi bagian atas dengan proporsional)
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
              child: InkWell(
                onTap: onTapCard,
                child: _buildThumbnail(),
              ),
            ),
          ),
          
          // 2. BAGIAN TEKS DAN ACTION (Padding dibuat proporsional)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: onTapCard,
                  child: Text(
                    (item.nama_menu ?? '').toTitleCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                // Deskripsi singkat
                if (item.deskripsi != null && item.deskripsi!.trim().isNotEmpty) ...[
                  Text(
                    item.deskripsi!.toLowerCase(), // Memaksa jadi huruf kecil semua
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 8),
                
                // Harga dan Tombol Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rp ${formatPrice(item.harga)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.orange),
                    ),
                    _buildActionButton(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (!isAvailable) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
        child: const Text('Habis', style: TextStyle(fontSize: 10, color: AppColors.error, fontWeight: FontWeight.w600)),
      );
    }

    if (currentQty == 0) {
      return GestureDetector(
        onTap: onTapAction,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(color: AppColors.darkRed, shape: BoxShape.circle),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
        ),
      );
    }

    // Jika sudah ada item di cart
    return GestureDetector(
      onTap: onTapAction,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green, width: 1.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Text(
            '$currentQty item', 
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final String imageUrl = item.image_url ?? '';
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl, 
        width: double.infinity, 
        height: double.infinity, 
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _fallbackIcon(item.kategori ?? ''),
      );
    }
    return _fallbackIcon(item.kategori ?? '');
  }

  Widget _fallbackIcon(String category) {
    IconData icon = Icons.lunch_dining_rounded;
    if (category.toLowerCase() == 'minuman') icon = Icons.local_drink_rounded;
    if (category.toLowerCase() == 'snack') icon = Icons.cookie_rounded;
    return Container(
      color: AppColors.orange.withOpacity(0.06),
      child: Center(child: Icon(icon, color: AppColors.orange, size: 40)),
    );
  }
}

extension StringCasingExtension on String {
  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.length <= 1 ? str.toUpperCase() : '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}')
      .join(' ');
}