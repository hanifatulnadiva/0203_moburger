import 'package:moburger/bloc/menu/menu_bloc.dart';
import 'package:moburger/core/contants/app_contants.dart';
import 'package:moburger/data/models/menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MenuRepository {
  final SupabaseClient _supabase;

  MenuRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<List<MenuModel>> getAllMenu ({int page =1, String? kategori}) async{
    try{
      final limit = AppConstants.defaultPageSize;
      final from  = (page -1)*limit;
      final to = from +limit -1;

      var query = _supabase
      .from('menu').select('*');
    
      if(kategori != null){
        query=query.eq('kategori', kategori);
      }
      final response = await query
      .order('created_at',ascending: false).range(from, to);
      return response.map((item)=> MenuModel.fromJson(item)).toList();
    }catch(e){
      throw Exception('Gagal mengambil data menu: $e');
    }
  }
  Future<MenuModel> getMenuById(String id)async{
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
  Future<MenuModel> updateMenu (String id, Map<String, dynamic> data) async{
    try{
      final response = await _supabase
      .from('menu').update(data).eq('id', id).select('*').single();
      return MenuModel.fromJson(response);
    }catch(e){
      throw Exception ('Gagal mengubah data menu:$e');
    }
  }
  //delete
  Future<void> deleteMenu(String id) async {
    try {
      await _supabase
          .from('menu')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Gagal menghapus data menu: $e');
    }
  }
}