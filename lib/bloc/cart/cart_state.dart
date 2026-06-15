import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  const CartState();
  
  @override
  List<Object?> get props => [];
}

// State saat aplikasi baru dibuka (keranjang kosong awal)
class CartInitial extends CartState {}
// State utama yang membawa data seluruh item di dalam keranjang
class CartLoaded extends CartState {
  final List<Map<String, dynamic>> cartItems;

  const CartLoaded({required this.cartItems});

  @override
  List<Object?> get props => [cartItems];
}