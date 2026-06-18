import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/data/repositories/order_repository.dart';
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
    on<LoadOrderDetailEvent>(_onLoadOrderDetail);
on<SearchOrderRequested>(_onSearchOrder);
  }

  Future<void> _onCreateOrder(CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // 1. Tambahkan pengecekan eksplisit
    final userId = _orderRepository.currentUserId;
    
    // Debugging untuk memastikan apa isinya
    print("DEBUG - OrderBloc: userId yang didapat adalah: $userId");

    if (userId == null || userId == 'undefined' || userId.isEmpty) {
      emit(OrderFailure('Sesi login tidak valid. Silakan login kembali.'));
      return;
    }

      final orderNumber = await _orderRepository.createOrderTransaction(
        userId: userId,
        totalPrice: event.totalPrice,
        namaCustomer: event.namaCustomer,
        orderType: event.orderType,
        items: event.items,
        notes: event.notes ?? "",
        snapToken: event.snapToken ?? ""
      );

      emit(OrderCreateSuccess(orderId: orderNumber));
    } catch (e) {
      emit(OrderFailure('Gagal membuat pesanan: $e'));
    }
  }

  Future<void> _onWatchOrder(WatchOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    try {
      await emit.forEach(
        _orderRepository.streamOrderById(event.orderId),
        onData: (orderData) {
          if (orderData == null) {
            return OrderFailure('Data pesanan tidak ditemukan.');
          }
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
    try {
      await _orderRepository.updateOrderStatus(
        orderId: event.orderId,
        status: event.status,
      );
      emit(OrderStatusUpdateSuccess());
    } catch (e) {
      emit(OrderFailure('Gagal update status: $e'));
    }
  }

  Future<void> _onLoadUserOrderHistory(LoadUserOrderHistoryEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getUserOrderHistory();
      emit(OrderHistoryLoadSuccess(order));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onLoadAdminOrderHistory(LoadAdminOrderHistoryEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getAllUserOrderHistoryForAdmin();
      emit(OrderHistoryLoadSuccess(order));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onLoadOrderDetail(LoadOrderDetailEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final items = await _orderRepository.getOrderDetail(event.orderId);
      emit(OrderDetailLoadSuccess(items: items));
    } catch (e) {
      emit(OrderFailure('Gagal mengambil detail pesanan: $e'));
    }
  }
  // Tambahkan event handler

  Future<void> _onSearchOrder(SearchOrderRequested event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      // Panggil fungsi search di Repository
      final orders = await _orderRepository.searchOrders(event.query);
      emit(OrderHistoryLoadSuccess(orders)); 
    } catch (e) {
      emit(OrderFailure('Gagal mencari pesanan: $e'));
    }
  }
}