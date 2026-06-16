import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<IncrementCartItem>(_onIncrementCartItem);
    on<DecrementCartItem>(_onDecrementCartItem);
    on<UpdateCartItem>(_onUpdateCartItem);
    on<ClearCart>(_onClearCart);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    List<Map<String, dynamic>> currentItems = [];

    if (state is CartLoaded) {
      currentItems = (state as CartLoaded).cartItems.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();
    }
    
    final Map<String, dynamic> itemToAdd = Map<String, dynamic>.from(event.item);
    
    // Pastikan ID diset
    if (itemToAdd.containsKey('id') && !itemToAdd.containsKey('menu_id')) {
      itemToAdd['menu_id'] = itemToAdd['id'];
    }
    
    // Fallback jika nama_menu tidak ada dari pengirim
    if (!itemToAdd.containsKey('nama_menu')) {
      itemToAdd['nama_menu'] = itemToAdd['nama'] ?? 'Unknown Item';
    }

    final index = currentItems.indexWhere(
      (item) => item['order_item_id'] == itemToAdd['order_item_id'],
    );

    if (index >= 0) {
      currentItems[index]['qty'] += itemToAdd['qty'];
    } else {
      currentItems.add(itemToAdd);
    }

    emit(CartLoaded(cartItems: currentItems));
  }

  void _onIncrementCartItem(IncrementCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded)
          .cartItems
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final index = updatedItems.indexWhere((item) => item['order_item_id'] == event.cartItemId);

      if (index >= 0) {
        updatedItems[index]['qty'] += 1;
        emit(CartLoaded(cartItems: updatedItems));
      }
    }
  }

  void _onDecrementCartItem(DecrementCartItem event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded)
          .cartItems
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

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
    print("DEBUG - Data yang dikirim ke BLoC: ${event.newItem}");
    if (state is CartLoaded) {
      final List<Map<String, dynamic>> updatedItems = (state as CartLoaded)
          .cartItems
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      final indexLama = updatedItems.indexWhere(
        (item) => item['order_item_id'] == event.oldCartItemId,
      );

      if (indexLama >= 0) {
        // Ambil data penting sebelum ditimpa
        final int simpanQtyLama = updatedItems[indexLama]['qty'];
        final String namaLama = updatedItems[indexLama]['nama_menu'] ?? 'Unknown Item';

        final indexDuplikat = updatedItems.indexWhere(
          (item) => item['order_item_id'] == event.newItem['order_item_id'] &&
              item['order_item_id'] != event.oldCartItemId,
        );

        if (indexDuplikat >= 0) {
          updatedItems[indexDuplikat]['qty'] += simpanQtyLama;
          updatedItems.removeAt(indexLama);
        } else {
          // Perbarui item dengan data baru
          updatedItems[indexLama] = Map<String, dynamic>.from(event.newItem);
          // Paksa set kembali qty dan nama_menu agar tidak hilang
          updatedItems[indexLama]['qty'] = simpanQtyLama;
          if (!updatedItems[indexLama].containsKey('nama_menu') || updatedItems[indexLama]['nama_menu'] == null) {
            updatedItems[indexLama]['nama_menu'] = namaLama;
          }
        }
        emit(CartLoaded(cartItems: updatedItems));
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(CartInitial());
  }
}