import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class CreateOrderEvent extends OrderEvent {
  final List<Map<String, dynamic>> items;
  final int totalPrice;
  final String namaCustomer;
  final String orderType;

  const CreateOrderEvent({
    required this.items, 
    required this.totalPrice, 
    required this.namaCustomer,
    required this.orderType
  });
}
/// Event untuk memantau satu order secara realtime (Stream)
class WatchOrderEvent extends OrderEvent {
  final String orderId;
  const WatchOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Event internal untuk memperbarui state saat stream Supabase memberikan data baru
class OrderUpdatedEvent extends OrderEvent {
  final dynamic order; // Menggunakan dynamic/OrderModel? untuk safety casting

  const OrderUpdatedEvent(this.order);

  @override
  List<Object?> get props => [order];
}

/// Event saat Admin mengubah status pesanan ('proses' | 'siap diambil' | 'selesai')
class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class LoadUserOrderHistoryEvent extends OrderEvent {}

class LoadAdminOrderHistoryEvent extends OrderEvent {}