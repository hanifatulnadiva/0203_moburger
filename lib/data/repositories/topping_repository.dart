import 'package:moburger/data/models/topping_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ToppingRepository {
  final SupabaseClient _supabase;

  ToppingRepository({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<ToppingModel>> getAllTopping({String? kategori}) async {
    try {
      var query = _supabase.from('topping').select('*');
      if (kategori != null) {
        query = query.eq('kategori', kategori);
      }
      final List<dynamic> response = await query;
      return response.map((item) => ToppingModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data topping: $e');
    }
  }

  Future<ToppingModel> createTopping(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('topping')
          .insert(data)
          .select('*')
          .single();
      return ToppingModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal menambahkan data topping: $e');
    }
  }

  Future<ToppingModel> updateTopping(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('topping')
          .update(data)
          .eq('id', id)
          .select('*')
          .single();
      return ToppingModel.fromJson(response);
    } catch (e) {
      throw Exception('Gagal mengubah data topping: $e');
    }
  }

  Future<ToppingModel> deleteTopping(String id) async {
    try {
      final data = await _supabase
          .from('topping')
          .delete()
          .eq('id', id)
          .single();
      return ToppingModel.fromJson(data);
    } catch (e) {
      throw Exception('Gagal menghapus data topping: $e');
    }
  }

  Future<List<ToppingModel>> getToppingsByKategori(String kategoriMenu) async {
    try {
      final String menuKategori = kategoriMenu.toLowerCase();
      List<dynamic> response = [];

      if (menuKategori == 'makanan') {
        response = await _supabase.from('topping').select().inFilter(
          'kategori',
          ['level', 'topping'],
        );
      } else if (menuKategori == 'minuman') {
        response = await _supabase
            .from('topping')
            .select()
            .eq('kategori', 'drink');
      } else {
        return [];
      }
      return response.map((item) => ToppingModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data topping berdasarkan kategori: $e');
    }
  }
}
