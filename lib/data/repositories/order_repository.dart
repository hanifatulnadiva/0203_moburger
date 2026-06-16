import 'package:moburger/data/models/order_item_details_model.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final SupabaseClient _supabase;

  OrderRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  // ==========================================
  // 1. FITUR FITUR PEMESANAN (USER & ADMIN)
  // ==========================================

  /// Membuat Order Pembayaran Baru (Mendukung pesanan via User atau Admin/Kasir)
  /// Membuat Order dengan memanggil SQL Function 'create_order_transaction'
  /// yang sudah kita buat sebelumnya di Supabase SQL Editor.
  Future<String> createOrderTransaction({
    required String userId,
    required int totalPrice,
    required String namaCustomer,
    required String orderType,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      // 1. Panggil SQL Function.
      // Supabase akan mengembalikan UUID dalam bentuk String.
      final String orderUuid = await _supabase.rpc('create_order_transaction', params: {
        'p_user_id': userId,
        'p_total_price': totalPrice,
        'p_nama_customer': namaCustomer,
        'p_order_type': orderType,
        'p_items': items,
      });
      print("DEBUG: UUID yang didapat dari database: $orderUuid");

      // 2. Sekarang kita punya UUID internal.
      // Jika Anda butuh order_number-nya, Anda bisa melakukan query
      // sekali lagi menggunakan UUID tersebut:
      final data = await _supabase
          .from('order')
          .select('order_number')
          .eq('id', orderUuid)
          .single();

      return data['order_number'] as String; // Kembalikan order_number ke UI
    } catch (e) {
      throw Exception('Gagal membuat transaksi order: $e');
    }
  }

  // ==========================================
  // 2. FITUR PEMANTAUAN REALTIME (UNTUK USER)
  // ==========================================

  /// Stream Realtime untuk memantau status satu pesanan tertentu milik user.
  Stream<OrderModel?> streamOrderById(String orderNumber) {
    return _supabase
        .from('order')
        .stream(primaryKey: ['id'])
        .eq('order_number', orderNumber) // Menggunakan order_number (string)
        .map((maps) {
          if (maps.isNotEmpty) {
            return OrderModel.fromJson(maps.first);
          }
          return null;
        });
  }

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    print("Attempting to update Supabase: order_number=$orderId, status=$status");
    try {
      final response = await _supabase
          .from('order')
          .update({'status': status})
          .eq('id', orderId)
          .select();
      print("Supabase update response: $response");
    } catch (e) {
      throw Exception('Gagal memperbarui status pesanan: $e');
    }
  }

  // ==========================================
  // 4. FITUR RIWAYAT / HISTORY PESANAN
  // ==========================================

  /// [ROLE: USER] Mengambil semua riwayat pesanan milik USER yang sedang login saat ini.
  Future<List<OrderModel>> getUserOrderHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Sesi login tidak ditemukan.');

      final response = await _supabase
          .from('order')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil history pesanan user: $e');
    }
  }

  /// [ROLE: ADMIN] Mengambil SEMUA riwayat pesanan tanpa pemaksaan join skema
  Future<List<OrderModel>> getAllUserOrderHistoryForAdmin() async {
    try {
      final response = await _supabase
          .from('order')
          .select('*')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;

      return data.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil seluruh history pesanan (Admin): $e');
    }
  }

  Future<List<OrderItemWithDetails>> getOrderDetail(String orderId) async {
    try {
      print("DEBUG: getOrderDetail dipanggil dengan orderId = $orderId");

      final response = await _supabase
          .from('order_item')
          .select('''
            id,
            quantity,
            subtotal,
            menu(nama_menu, harga),
            order_item_topping(
              topping(nama_topping)
            )
          ''')
          .eq('order_id', orderId);

      print("DEBUG: raw response getOrderDetail = $response");

      final List<dynamic> data = response as List<dynamic>;

      print("DEBUG: jumlah item ditemukan = ${data.length}");

      return data
          .map((item) => OrderItemWithDetails.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error di Repository: $e");
      throw e;
    }
  }
}