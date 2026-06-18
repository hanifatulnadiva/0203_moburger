/// Representasi satu baris `order_item` beserta detail menu & topping
/// yang sudah di-join lewat query Supabase (nested select).
///
/// Bentuk JSON yang diharapkan (hasil select dengan nested relation):
/// ```
/// {
///   "id": "...",
///   "quantity": 2,
///   "subtotal": 45000,
///   "menu": { "nama_menu": "...", "harga": 20000, "image_url": "..." },
///   "order_item_topping": [
///     { "topping": { "nama_topping": "Keju", "harga": 5000 } }
///   ]
/// }
/// ```
class OrderItemWithDetails {
  final String id;
  final String menuName;
  final int quantity;
  final double price;
  final List<String> toppingNames;
  final double subTotal;
  final String? imageUrl;

  const OrderItemWithDetails({
    required this.id,
    required this.menuName,
    required this.quantity,
    required this.price,
    required this.toppingNames,
    required this.subTotal,
    this.imageUrl,
  });

  factory OrderItemWithDetails.fromJson(Map<String, dynamic> json) {
    final menu = json['menu'] as Map<String, dynamic>?;

    final List<dynamic> toppingPivot = json['order_item_topping'] ?? [];
    final names = toppingPivot
        .map((p) {
          final topping = p['topping'] as Map<String, dynamic>?;
          return topping?['nama_topping']?.toString();
        })
        .whereType<String>()
        .toList();

    final quantity = json['quantity'] is String
        ? int.tryParse(json['quantity']) ?? 0
        : (json['quantity'] ?? 0) as int;

    final price = (menu?['harga'] as num?)?.toDouble() ?? 0;

    // Pakai subtotal yang sudah tersimpan di database (mencerminkan harga
    // saat transaksi terjadi, termasuk topping). Hanya fallback ke
    // quantity * harga menu jika subtotal tidak tersedia di response.
    final subtotalRaw = json['subtotal'];
    final subtotal = subtotalRaw is String
        ? double.tryParse(subtotalRaw) ?? (quantity * price)
        : (subtotalRaw as num?)?.toDouble() ?? (quantity * price);

    return OrderItemWithDetails(
      id: json['id']?.toString() ?? '',
      menuName: menu?['nama_menu']?.toString() ?? 'Menu tidak ditemukan',
      quantity: quantity,
      price: price,
      imageUrl: menu?['image_url']?.toString(),
      toppingNames: names,
      subTotal: subtotal,
    );
  }
}