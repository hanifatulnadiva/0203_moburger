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
    if (order.payment_status != 'settlement') {
      return 0; // Menunggu Pembayaran
    }
    switch (order.status) {
      case 'pending':
        return 1; // Pembayaran Diterima, order belum diproses
      case 'prosess':
        return 2; // Pesanan Diproses
      case 'siap diambil':
        return 3; // Pesanan Siap Diambil
      case 'selesai':
        return 4; // Pesanan Selesai
      default:
        return 2;
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