import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/data/repositories/order_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;

  OrderBloc({required OrderRepository orderRepository})
      : _orderRepository = orderRepository,
        super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<WatchOrderEvent>(_onWatchOrder);
    on<UpdateOrderStatusEvent>(_onUpdateOrderStatus);
    on<LoadUserOrderHistoryEvent>(_onLoadUserOrderHistory);
    on<LoadAdminOrderHistoryEvent>(_onLoadAdminOrderHistory);
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final payload = event.items.map((item) => {
        "menu_id": int.parse(item['id'].toString()),
        "quantity": item['qty'],
        "subtotal": item['harga'] * item['qty'],
        "toppings": item['topping_ids'] ?? [] 
      }).toList();

      final response = await Supabase.instance.client.rpc('create_order_transaction', params: {
        'p_user_id': Supabase.instance.client.auth.currentUser!.id,
        'p_total_price': event.totalPrice,
        'p_nama_customer': event.namaCustomer,
        'p_order_type': 'online',
        'p_items': payload
      });

      if (response != null) {
        emit(OrderCreateSuccess(orderId: response.toString()));
      } else {
        emit(OrderFailure('Gagal membuat pesanan: Response kosong.'));
      }
    } catch (e) {
      emit(OrderFailure('Gagal membuat pesanan: $e'));
    }
  }

  Future<void> _onWatchOrder(WatchOrderEvent event, Emitter<OrderState> emit) async {
    // Gunakan OrderLoading hanya saat pertama kali membuka stream
    emit(OrderLoading());
    
    try {
      await emit.forEach(
        _orderRepository.streamOrderById(event.orderId),
        onData: (orderData) {
          if (orderData == null) {
            return OrderFailure('Data pesanan tidak ditemukan.');
          }
          // Setiap ada update di database, state ini akan ter-update otomatis
          return OrderWatchSuccess(orderData);
        },
        onError: (error, stackTrace) {
          return OrderFailure('Gagal memantau perubahan status: $error');
        },
      );
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(UpdateOrderStatusEvent event, Emitter<OrderState> emit) async {
    // TIDAK menggunakan emit(OrderLoading()) agar stream di _onWatchOrder tetap aktif
    try {
      await _orderRepository.updateOrderStatus(
        orderNumber: event.orderId,
        status: event.status,
      );
    } catch (e) {
      // Emit error ke listener jika gagal, tapi jangan matikan stream
      emit(OrderFailure('Gagal update status: $e'));
    }
  }

  Future<void> _onLoadUserOrderHistory(LoadUserOrderHistoryEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getUserOrderHistory();
      emit(OrderHistoryLoadSuccess(orders));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onLoadAdminOrderHistory(LoadAdminOrderHistoryEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.getAllUserOrderHistoryForAdmin();
      emit(OrderHistoryLoadSuccess(orders));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }
}