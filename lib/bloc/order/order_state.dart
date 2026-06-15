import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/order_model.dart';

abstract class OrderState extends Equatable {
  const OrderState();
  
  @override
  List<Object?> get props => [];
}

/// State awal
class OrderInitial extends OrderState {}

/// State loading saat proses hit API/Supabase berlangsung
class OrderLoading extends OrderState {}

/// State sukses ketika BERHASIL MEMBUAT ORDER (mengembalikan order beserta snap_token)
class OrderCreateSuccess extends OrderState {
  final String orderId;
  const OrderCreateSuccess({required this.orderId});
}

/// State saat memantau status pesanan secara REALTIME (Sangat berguna untuk halaman Tracking User)
class OrderWatchSuccess extends OrderState {
  final OrderModel order; // Gunakan tipe data OrderModel

  OrderWatchSuccess(this.order);

  // Sesuaikan getter untuk membaca dari properti class OrderModel
  int get statusIndex {
    switch (order.status) { // Asumsikan ada field 'status' di OrderModel
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

/// State sukses saat mengambil daftar history pesanan (Bisa untuk List User atau List Admin)
class OrderHistoryLoadSuccess extends OrderState {
  final List<OrderModel> orders;
  const OrderHistoryLoadSuccess(this.orders);

  @override
  List<Object?> get props => [orders];
}

/// State sukses saat admin mengubah status jalannya pesanan
class OrderStatusUpdateSuccess extends OrderState {}


/// State ketika terjadi kendala / error
class OrderFailure extends OrderState {
  final String errorMessage;
  const OrderFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}