import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class FetchCart extends CartEvent {}

// Event untuk memasukkan burger baru ke keranjang
class AddToCart extends CartEvent {
  final Map<String, dynamic> item;
  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class IncrementCartItem extends CartEvent {
  final String cartItemId; 
  const IncrementCartItem(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class DecrementCartItem extends CartEvent {
  final String cartItemId;
  const DecrementCartItem(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class UpdateCartItem extends CartEvent {
  final String oldCartItemId;       // ID variasi lama yang mau diganti
  final Map<String, dynamic> newItem; // Data kustomisasi baru hasil edit

  const UpdateCartItem({required this.oldCartItemId, required this.newItem});

  @override
  List<Object?> get props => [oldCartItemId, newItem];
}
// Event untuk mengosongkan keranjang (misal setelah sukses checkout)
class ClearCart extends CartEvent {}