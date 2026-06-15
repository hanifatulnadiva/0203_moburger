// lib/data/repositories/report_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_model.dart';

class ReportRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ReportModel> fetchReport(DateTime start, DateTime end) async {
    // Memanggil SQL Function (RPC) yang sudah kita buat di database
    final response = await _supabase.rpc('get_full_report', params: {
      'start_date': start.toIso8601String(), // Pastikan format ISO 8601 (2026-06-14T00:00:00.000)
      'end_date': end.toIso8601String(),
    });
    return ReportModel.fromJson(response);
  }
}