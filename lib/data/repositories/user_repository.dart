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
          'role': 'customer',
        },
      );

      if (response.user == null) {
        throw const AuthException('Registrasi gagal, user kosong.');
      }

      return _mapSupabaseUserToUserModel(response.user!);
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

      return _mapSupabaseUserToUserModel(response.user!);
    } on AuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Terjadi kesalahan saat login: $e');
    }
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

  UserModel _mapSupabaseUserToUserModel(User supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};

    final namaDariGoogle = metadata['full_name'] ?? metadata['name'] ?? '';

    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      nama_lengkap: metadata['nama_lengkap'] ?? namaDariGoogle,
      nohp: metadata['nohp'] ?? '',
      role: metadata['role'] ?? 'customer', 
    );
  }

  Future<UserModel?> getCurrentUser() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return _mapSupabaseUserToUserModel(user);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}