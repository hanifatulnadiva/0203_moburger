import 'package:equatable/equatable.dart';
import 'package:moburger/data/models/order_item_details_model.dart';

class OrderModel extends Equatable{
  final String id;
  final String order_number;
  final String order_type;
  final String status;
  final int total_price;
  final String user_id;
  final String? nama_customer;
  final String payment_status;
  final String? payment_method;
  final String? transaction_id;
  final String? snap_token;
  final String? notes;
  final String createdAt;
  final String updateAt;
  final List<OrderItemWithDetails>? items;

  const OrderModel({
    required this.id,
    required this.order_number,
    required this.order_type,
    required this.status,
    required this.total_price,
    required this.user_id,
    required this.payment_status,
    required this.createdAt,
    required this.updateAt,
    this.nama_customer,
    this.payment_method,
    this.transaction_id,
    this.snap_token,
    this.notes,
    this.items,
    
  });
  factory OrderModel.fromJson(Map<String,dynamic> json){
    String? namaFinal = json['nama_customer'];

    if (namaFinal == null || namaFinal.isEmpty) {
      if (json['users'] != null && json['users']['nama_lengkap'] != null) {
        namaFinal = json['users']['nama_lengkap'];
      }
    }
    return OrderModel(
      id: json['id'] ?? '',
      order_number: json['order_number'] ?? '',
      order_type: json['order_type'] ?? '',
      status: json['status'] ?? 'pending',
      total_price: json['total_price'] is String 
        ? int.tryParse(json['total_price']) ?? 0 
        : (json['total_price'] ?? 0),
      user_id: json['user_id'] ?? '',
      payment_status: json['payment_status']??'pending',
      nama_customer: namaFinal,
      payment_method: json['payment_method'],
      transaction_id: json['transaction_id'],
      snap_token: json['snap_token'],
      notes: json['notes'],
      createdAt: json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      updateAt: json['update_at']?.toString() ?? DateTime.now().toIso8601String(),
      items: json['order_item'] != null
          ? (json['order_item'] as List)
              .map((i) => OrderItemWithDetails.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
  @override
  List<Object?> get props=>[id,order_number, order_type, status, total_price, 
  user_id, payment_status, nama_customer, payment_method, transaction_id, snap_token, 
  notes, createdAt, items, updateAt];
}