import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<IncrementCartItem>(_onIncrementCartItem);
    on<DecrementCartItem>(_onDecrementCartItem);
    on<UpdateCartItem>(_onUpdateCartItem); // Registrasi event update di sini
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    List<Map<String, dynamic>> currentItems = [];
    
    if (state is CartLoaded) {
      currentItems = (state as CartLoaded).cartItems.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    }

    final index = currentItems.indexWhere((item) => item['cart_item_id'] == event.item['cart_item_id']);

    if (index >= 0) {
      currentItems[index]['qty'] += event.item['qty'];
    } else {
      currentItems.add(Map<String, dynamic>.from(event.item));
    }

    emit(CartLoaded(cartItems: currentItems));
  }

  void _onIncrementCartItem(IncrementCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded).cartItems.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      final index = updatedItems.indexWhere((item) => item['cart_item_id'] == event.cartItemId);

      if (index >= 0) {
        updatedItems[index]['qty'] += 1;
        emit(CartLoaded(cartItems: updatedItems));
      }
    }
  }

  void _onDecrementCartItem(DecrementCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded).cartItems.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      final index = updatedItems.indexWhere((item) => item['cart_item_id'] == event.cartItemId);

      if (index >= 0) {
        if (updatedItems[index]['qty'] > 1) {
          updatedItems[index]['qty'] -= 1;
          emit(CartLoaded(cartItems: updatedItems));
        } else {
          updatedItems.removeAt(index);
          
          if (updatedItems.isEmpty) {
            emit(CartInitial());
          } else {
            emit(CartLoaded(cartItems: updatedItems));
          }
        }
      }
    }
  }

  // LOGIKA UTAS: Memperbarui variasi item lama tanpa merusak variasi menu lainnya
  void _onUpdateCartItem(UpdateCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded).cartItems.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      // 1. Cari baris index item variasi lama yang mau diedit
      final indexLama = updatedItems.indexWhere((item) => item['cart_item_id'] == event.oldCartItemId);

      if (indexLama >= 0) {
        // Simpan jumlah quantity lama supaya tidak berubah/mereset menjadi 1 saat kustomisasi diganti
        final int simpanQtyLama = updatedItems[indexLama]['qty'];

        // 2. Cek apakah variasi BARU hasil edit ternyata kembar dengan variasi LAIN yang sudah ada di keranjang
        final indexDuplikat = updatedItems.indexWhere(
          (item) => item['cart_item_id'] == event.newItem['cart_item_id'] && item['cart_item_id'] != event.oldCartItemId
        );

        if (indexDuplikat >= 0) {
          // Jika kembar dengan variasi lain, gabungkan quantity-nya ke variasi tersebut, lalu hapus baris yang lama
          updatedItems[indexDuplikat]['qty'] += simpanQtyLama;
          updatedItems.removeAt(indexLama);
        } else {
          // Jika kombinasinya benar-benar baru dan unik, timpa data lama dengan data setelan kustomisasi baru
          updatedItems[indexLama] = Map<String, dynamic>.from(event.newItem);
          updatedItems[indexLama]['qty'] = simpanQtyLama; // Kunci qty asli agar tetap terjaga
        }
        
        emit(CartLoaded(cartItems: updatedItems));
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
}