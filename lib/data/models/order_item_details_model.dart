class OrderItemWithDetails {
  final String id;
  final String menuName;
  final int quantity;
  final double price;
  final List<String> toppingNames;
  final double subTotal;
  final String? imageUrl;

  OrderItemWithDetails({
    required this.id,
    required this.menuName,
    required this.quantity,
    required this.price,
    required this.toppingNames,
    this.imageUrl,
  }) : subTotal = quantity * price;

  factory OrderItemWithDetails.fromJson(Map<String, dynamic> json) {
    final List<dynamic> toppingPivot = json['order_item_topping'] ?? [];
    final names = toppingPivot.map((p) => p['topping']['nama_topping'].toString()).toList();

    return OrderItemWithDetails(
      id: json['id'],
      menuName: json['menu']['nama_menu'],
      quantity: json['quantity'],
      price: (json['menu']['harga'] as num).toDouble(),
      imageUrl: json['menu']['image_url'],
      toppingNames: names,
    );
  }
}