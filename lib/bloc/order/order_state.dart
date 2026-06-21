import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/order_item_topping_model.dart';
import 'package:moburger/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {
  final bool isFirstLoad;
  const OrderLoading({this.isFirstLoad = false});
}

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
  final bool hasReachedMax;

  const OrderHistoryLoadSuccess({
    required this.orders,
    required this.hasReachedMax,
  });

  @override
  List<Object?> get props => [orders, hasReachedMax];
}

class OrderStatusUpdateSuccess extends OrderState {}

class OrderFailure extends OrderState {
  final String errorMessage;
  const OrderFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class OrderDetailLoadSuccess extends OrderState {
  final List<OrderItemTopping> items;
  OrderDetailLoadSuccess({required this.items});

  @override
  List<Object?> get props => [items];
}
