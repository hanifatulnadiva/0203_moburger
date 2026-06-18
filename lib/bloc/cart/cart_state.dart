import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// State saat keranjang baru diinisialisasi (kosong)
class CartInitial extends CartState {}

/// State saat keranjang memiliki data
class CartLoaded extends CartState {
  final List<Map<String, dynamic>> cartItems;

  const CartLoaded({required this.cartItems});

  @override
  List<Object?> get props => [cartItems];

  /// Digunakan untuk menyimpan ke storage (di panggil oleh HydratedBloc toJson)
  Map<String, dynamic> toMap() {
    return {
      'cartItems': cartItems,
    };
  }

  /// Digunakan untuk memuat dari storage (di panggil oleh HydratedBloc fromJson)
  factory CartLoaded.fromMap(Map<String, dynamic> map) {
    return CartLoaded(
      cartItems: List<Map<String, dynamic>>.from(
        (map['cartItems'] as List).map((x) => Map<String, dynamic>.from(x)),
      ),
    );
  }
}