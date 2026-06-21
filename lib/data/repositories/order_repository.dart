import 'package:moburger/data/models/order_item_topping_model.dart';
import 'package:moburger/data/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderRepository {
  final SupabaseClient _supabase;

  OrderRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Membuat Order dengan memanggil SQL Function 'create_order_transaction'
  Future<String> createOrderTransaction({
    required String userId,
    required int totalPrice,
    required String namaCustomer,
    required String orderType,
    required List<Map<String, dynamic>> items,
    required String notes,
    required String snapToken,
  }) async {
    // 1. MEKANISME PEMBERSIHAN DATA (PENTING UNTUK MENCEGAH 'undefined')
    final String cleanUserId = (userId == 'undefined' || userId.isEmpty)
        ? (_supabase.auth.currentUser?.id ?? '')
        : userId;

    if (cleanUserId.isEmpty) {
      throw Exception(
        'Gagal membuat pesanan: User ID tidak ditemukan atau tidak valid.',
      );
    }

    print("DEBUG: Mengirim RPC ke Supabase dengan UserID: $cleanUserId");

    try {
      // 2. Panggil SQL Function
      final dynamic orderUuid = await _supabase.rpc(
        'create_order_transaction',
        params: {
          'p_user_id': cleanUserId,
          'p_total_price': totalPrice,
          'p_nama_customer': namaCustomer,
          'p_order_type': orderType,
          'p_items': items,
          'p_notes': notes,
          'p_snap_token': snapToken,
        },
      );

      print("DEBUG: UUID sukses didapat: $orderUuid");
      final data = await _supabase
          .from('order')
          .select('order_number')
          .eq('id', orderUuid)
          .single();

      return data['order_number'] as String;
    } catch (e) {
      print("DEBUG: Error RPC Detail: $e");
      throw Exception('Gagal membuat transaksi order: $e');
    }
  }

  Future<String> createOfflineOrder({
    required int totalPrice,
    required String namaCustomer,
    required List<Map<String, dynamic>> items,
    required String notes,
  }) async {
    try {
      final dynamic orderUuid = await _supabase.rpc(
        'create_order_transaction',
        params: {
          'p_user_id': null,
          'p_total_price': totalPrice,
          'p_nama_customer': namaCustomer,
          'p_order_type': 'offline',
          'p_items': items,
          'p_notes': notes,
          'p_snap_token': 'CASH_PAYMENT', 
        },
      );

      final data = await _supabase
          .from('order')
          .select('order_number')
          .eq('id', orderUuid)
          .single();

      return data['order_number'] as String;
    } catch (e) {
      print("DEBUG ERROR: $e");
      throw Exception('Gagal membuat pesanan offline: $e');
    }
  }

  /// Stream Realtime untuk memantau status pesanan
  Stream<OrderModel?> streamOrderById(String orderNumber) {
    return _supabase
        .from('order')
        .stream(primaryKey: ['id'])
        .eq('order_number', orderNumber)
        .map((maps) {
          if (maps.isNotEmpty) {
            return OrderModel.fromJson(maps.first);
          }
          return null;
        });
  }

  Future<List<OrderModel>> searchOrders(String query) async {
    final response = await _supabase
        .from('order')
        .select('*, order_item(*, menu(*))')
        .ilike(
          'nama_customer',
          '%$query%',
        ) // ILIKE untuk pencarian tidak peka huruf besar/kecil
        .order('created_at', ascending: false);
    return (response as List<dynamic>)
        .map((json) => OrderModel.fromJson(json))
        .toList();
  }

  /// Update status pesanan
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('order')
          .update({'status': status})
          .eq('id', orderId);
    } catch (e) {
      throw Exception('Gagal memperbarui status pesanan: $e');
    }
  }

  Future<List<OrderModel>> getUserOrderHistory({required int page}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Sesi login tidak ditemukan.');

      final int limit = 10;
      final int from = (page - 1) * limit;
      final int to = from + limit - 1;

      final response = await _supabase
          .from('order')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(from, to); 

      return (response as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil history pesanan: $e');
    }
  }

  /// Ambil riwayat pesanan ADMIN
  Future<List<OrderModel>> getAllUserOrderHistoryForAdmin() async {
    try {
      final response = await _supabase
          .from('order')
          .select('''
            *,
            users(nama_lengkap),
            order_item(
              id,
              quantity,
              subtotal,
              menu(nama_menu, harga, image_url),
              order_item_topping(
                topping(nama_topping)
              )
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil seluruh history pesanan: $e');
    }
  }

  /// Ambil detail order
  Future<List<OrderItemTopping>> getOrderDetail(String identifier) async {
    try {
      String orderId = "";
      if (identifier.length == 36 && identifier.contains('-')) {
        orderId = identifier;
      } else {
        final orderData = await _supabase
            .from('order')
            .select('id')
            .eq(
              'order_number',
              identifier,
            ) // Cari UUID berdasarkan order_number
            .maybeSingle();

        if (orderData == null) {
          throw Exception('Pesanan dengan nomor $identifier tidak ditemukan.');
        }
        orderId = orderData['id'];
      }

      // 2. Ambil detail item menggunakan orderId (UUID) yang sudah pasti benar
      final response = await _supabase
          .from('order_item')
          .select('''
            id,
            quantity,
            subtotal,
            menu(nama_menu, harga, image_url),
            order_item_topping(
              topping(nama_topping)
            )
          ''')
          .eq('order_id', orderId);

      return (response as List<dynamic>)
          .map(
            (item) => OrderItemTopping.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print("DEBUG ERROR: $e");
      throw Exception('Gagal mengambil detail pesanan: $e');
    }
  }
}
