import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moburger/data/repositories/order_repository.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;
  int _page = 1;

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
    if (event.isRefresh) {
      _page = 1;
      emit(OrderLoading()); // Full screen loader
    } else {
      // Jika bukan refresh (load more), jangan emit OrderLoading agar layar tidak kedip
    }

    try {
      // 2. Ambil data dengan parameter page (pastikan repository mendukung ini)
      final newOrders = await _orderRepository.getUserOrderHistory(page: _page);
      
      // 3. Tentukan apakah sudah mencapai halaman terakhir (asumsi 10 item per page)
      final bool hasReachedMax = newOrders.length < 10;

      // 4. Logika State
      if (state is OrderHistoryLoadSuccess && !event.isRefresh) {
        final oldOrders = (state as OrderHistoryLoadSuccess).orders;
        emit(OrderHistoryLoadSuccess(
          orders: [...oldOrders, ...newOrders], 
          hasReachedMax: hasReachedMax
        ));
      } else {
        emit(OrderHistoryLoadSuccess(
          orders: newOrders, 
          hasReachedMax: hasReachedMax
        ));
      }

      // 5. Increment page jika ada data baru
      if (newOrders.isNotEmpty) {
        _page++;
      }
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onLoadAdminOrderHistory(LoadAdminOrderHistoryEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final order = await _orderRepository.getAllUserOrderHistoryForAdmin();
      emit(OrderHistoryLoadSuccess(orders:order, hasReachedMax: true));
    } catch (e) {
      emit(OrderFailure(e.toString()));
    }
  }

  Future<void> _onLoadOrderDetail(LoadOrderDetailEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    print("DEBUG: Event LoadOrderDetail diterima. ID: ${event.orderId}"); // <--- Tambah ini
    
    try {
      final items = await _orderRepository.getOrderDetail(event.orderId);
      print("DEBUG: Data berhasil diambil. Jumlah item: ${items.length}"); // <--- Tambah ini
      
      emit(OrderDetailLoadSuccess(items: items));
    } catch (e) {
      print("DEBUG: Error di Repository: $e"); // <--- Tambah ini
      emit(OrderFailure('Gagal mengambil detail pesanan: $e'));
    }
  }
  // Tambahkan event handler

  Future<void> _onSearchOrder(SearchOrderRequested event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await _orderRepository.searchOrders(event.query);
      emit(OrderHistoryLoadSuccess(orders:orders, hasReachedMax: true)); 
    } catch (e) {
      emit(OrderFailure('Gagal mencari pesanan: $e'));
    }
  }
}