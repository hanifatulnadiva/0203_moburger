import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/order_item_details_model.dart';
import 'package:moburger/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreateSuccess extends OrderState {
  final String orderId;
  const OrderCreateSuccess({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class OrderWatchSuccess extends OrderState {
  final OrderModel order;
  OrderWatchSuccess(this.order);

  int get statusIndex {
    switch (order.status) {
      case 'menunggu_pembayaran': return 0;
      case 'pembayaran_berhasil': return 1;
      case 'diproses': return 2;
      case 'siap_diambil': return 3;
      case 'selesai': return 4;
      default: return 0;
    }
  }

  @override
  List<Object?> get props => [order];
}

class OrderHistoryLoadSuccess extends OrderState {
  final List<OrderModel> orders;
  const OrderHistoryLoadSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

class OrderStatusUpdateSuccess extends OrderState {}

class OrderFailure extends OrderState {
  final String errorMessage;
  const OrderFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class OrderDetailLoadSuccess extends OrderState {
  final List<OrderItemWithDetails> items;
  OrderDetailLoadSuccess({required this.items});

  @override
  List<Object?> get props => [items];
}