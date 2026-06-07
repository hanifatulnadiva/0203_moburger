import 'package:moburger/data/models/menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  final SupabaseClient _supabase;

  MenuRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<MenuModel>> getAllMenu ({String? kategori}) async{
    try{
      var query = _supabase
      .from('menu').select('*');
      if(kategori != null){
        query=query.eq('kategori', kategori);
      }
      final List<dynamic> response = await query;
      return response.map((item)=> MenuModel.fromJson(item)).toList();
    }catch(e){
      throw Exception('Gagal mengambil data menu: $e');
    }
  }
  Future<MenuModel> getMenuById(int id)async{
    try{
      final response = await _supabase 
        .from('menu').select('*').eq('id', id).single();
      return MenuModel.fromJson(response);
    }catch(e){
      throw Exception('Gagal mengambil detail menu : $e');
    }
  }

  //Add menu (admin)
  Future<MenuModel> createMenu (Map<String, dynamic> data) async{
    try{
      final response = await _supabase
      .from('menu').insert(data).select('*').single();
      return MenuModel.fromJson(response);
    }catch(e){
      throw Exception ('Gagal menambahkan data menu:$e');
    }
  }

  //update menu(admin)
  Future<MenuModel> updateMenu (int id, Map<String, dynamic> data) async{
    try{
      final response = await _supabase
      .from('menu').update(data).eq('id', id).select('*').single();
      return MenuModel.fromJson(response);
    }catch(e){
      throw Exception ('Gagal mengubah data menu:$e');
    }
  }
  //delete
  Future<MenuModel> deleteMenu (int id) async{
    try{
      final data = await _supabase
      .from('menu').delete().eq('id', id).single();
      return MenuModel.fromJson(data);
    }catch(e){
      throw Exception ('Gagal menghapus data menu:$e');
    }
  }
}