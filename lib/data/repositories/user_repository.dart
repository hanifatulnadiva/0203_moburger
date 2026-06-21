import 'package:moburger/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository({SupabaseClient? supabaseClient})
      : _supabase = supabaseClient ?? Supabase.instance.client;

  Future<UserModel> register({
    required String email,
    required String password,
    required String nama_lengkap,
    required String nohp,
  }) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nama_lengkap': nama_lengkap,
          'nohp': nohp,
        },
      );

      if (response.user == null) {
        throw const AuthException('Registrasi gagal, user kosong.');
      }
      return await _fetchUserFromTable(response.user!.id, email.trim());
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat registrasi: $e');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Login gagal, user tidak ditemukan.');
      }

      return await _fetchUserFromTable(response.user!.id, response.user!.email ?? '');
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return await _fetchUserFromTable(user.id, user.email ?? '');
  }

  Future<UserModel> _fetchUserFromTable(String uid, String email) async {
    print('[DEBUG] uid yang dicari: $uid');
    print('[DEBUG] email yang dicari: $email');
    final allData = await _supabase.from('users').select();
    print('[DEBUG] Semua data di tabel users: $allData');

    final data = await _supabase
        .from('users')
        .select()
        .eq('id', uid)
        .single();

    return UserModel.fromJson({...data, 'email': email});
  }

  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.moburger://login-callback/',
      );
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat Google Sign-In: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel> updateProfile({
    required String id,
    required String namaLengkap,
    required String nohp,
  }) async {
    try {
      await _supabase
          .from('users')
          .update({
            'nama_lengkap': namaLengkap,
            'nohp': nohp,
          })
          .eq('id', id);

      return await _fetchUserFromTable(id, _supabase.auth.currentUser!.email ?? '');
    } catch (e) {
      throw Exception('Gagal update profile: $e');
    }
  }

  Future<void> changePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw Exception('Gagal ganti password: $e');
    }
  }
}