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
  final String? notes;
  final String? snapToken;

  const CreateOrderEvent({
    required this.items, 
    required this.totalPrice, 
    required this.namaCustomer,
    required this.orderType,
    this.notes,
    this.snapToken
  });
}
/// Event untuk memantau satu order secara realtime (Stream)
class WatchOrderEvent extends OrderEvent {
  final String orderId;
  const WatchOrderEvent({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderUpdatedEvent extends OrderEvent {
  final dynamic order; 

  const OrderUpdatedEvent(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrderStatusEvent extends OrderEvent {
  final String orderId;
  final String status;

  const UpdateOrderStatusEvent({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class LoadUserOrderHistoryEvent extends OrderEvent {}

class LoadAdminOrderHistoryEvent extends OrderEvent {}

class LoadOrderDetailEvent extends OrderEvent {
  final String orderId;
  const LoadOrderDetailEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}