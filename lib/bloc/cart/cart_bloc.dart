import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'package:hydrated_bloc/hydrated_bloc.dart';

// 1. Ubah extends Bloc menjadi HydratedBloc
class CartBloc extends HydratedBloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<IncrementCartItem>(_onIncrementCartItem);
    on<DecrementCartItem>(_onDecrementCartItem);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<ClearCart>(_onClearCart);
  }

  // --- LOGIKA STORAGE (HydratedBloc) ---
  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      // Mengambil data dari storage dan mengubahnya kembali ke state
      if (json['cartItems'] != null) {
        return CartLoaded(cartItems: List<Map<String, dynamic>>.from(json['cartItems']));
      }
      return CartInitial();
    } catch (_) {
      return CartInitial();
    }
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    // Menyimpan state ke storage
    if (state is CartLoaded) {
      return {'cartItems': state.cartItems};
    }
    return null;
  }
  // ------------------------------------

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    List<Map<String, dynamic>> currentItems = [];
    if (state is CartLoaded) {
      currentItems = (state as CartLoaded).cartItems.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    
    final Map<String, dynamic> itemToAdd = Map<String, dynamic>.from(event.item);
    
    if (itemToAdd.containsKey('id') && !itemToAdd.containsKey('menu_id')) {
      itemToAdd['menu_id'] = itemToAdd['id'];
    }
    if (!itemToAdd.containsKey('nama_menu')) {
      itemToAdd['nama_menu'] = itemToAdd['nama'] ?? 'Unknown Item';
    }

    final index = currentItems.indexWhere((item) => item['order_item_id'] == itemToAdd['order_item_id']);

    if (index >= 0) {
      currentItems[index]['qty'] += itemToAdd['qty'];
    } else {
      currentItems.add(itemToAdd);
    }
    emit(CartLoaded(cartItems: currentItems));
  }

  void _onIncrementCartItem(IncrementCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded).cartItems.map((item) => Map<String, dynamic>.from(item)).toList();
      final index = updatedItems.indexWhere((item) => item['order_item_id'] == event.cartItemId);
      if (index >= 0) {
        updatedItems[index]['qty'] += 1;
        emit(CartLoaded(cartItems: updatedItems));
      }
    }
  }

  void _onDecrementCartItem(DecrementCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded).cartItems.map((item) => Map<String, dynamic>.from(item)).toList();
      final index = updatedItems.indexWhere((item) => item['order_item_id'] == event.cartItemId);
      if (index >= 0) {
        if (updatedItems[index]['qty'] > 1) {
          updatedItems[index]['qty'] -= 1;
        } else {
          updatedItems.removeAt(index);
        }
        if (updatedItems.isEmpty) {
          emit(CartInitial());
        } else {
          emit(CartLoaded(cartItems: updatedItems));
        }
      }
    }
  }

  void _onUpdateCartItem(UpdateCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded).cartItems.map((item) => Map<String, dynamic>.from(item)).toList();
      final indexLama = updatedItems.indexWhere((item) => item['order_item_id'] == event.oldCartItemId);
      if (indexLama >= 0) {
        final int simpanQtyLama = updatedItems[indexLama]['qty'];
        final String namaLama = updatedItems[indexLama]['nama_menu'] ?? 'Unknown Item';
        final indexDuplikat = updatedItems.indexWhere((item) => item['order_item_id'] == event.newItem['order_item_id'] && item['order_item_id'] != event.oldCartItemId);

        if (indexDuplikat >= 0) {
          updatedItems[indexDuplikat]['qty'] += simpanQtyLama;
          updatedItems.removeAt(indexLama);
        } else {
          updatedItems[indexLama] = Map<String, dynamic>.from(event.newItem);
          updatedItems[indexLama]['qty'] = simpanQtyLama;
          if (updatedItems[indexLama]['nama_menu'] == null) updatedItems[indexLama]['nama_menu'] = namaLama;
        }
        emit(CartLoaded(cartItems: updatedItems));
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
}