import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:moburger/bloc/report/report_bloc.dart';
import 'package:moburger/core/contants/colors.dart'; // Pastikan path benar
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/report_model.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  
  @override
  void initState() {
    super.initState();
    _testSupabase(); 
    final today = DateTimeRange(start: DateTime.now(), end: DateTime.now());
    context.read<ReportBloc>().add(FetchReportData(today));
  }


  Future<void> _testSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase.rpc('get_report_data', params: {
        'start_date': DateTime.now().toIso8601String(),
        'end_date': DateTime.now().toIso8601String(),
      });
      print("HASIL MENTAH DARI SUPABASE: $response");
    } catch (e) {
      print("ERROR MENTAH: $e");
    }
  }
  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      context.read<ReportBloc>().add(FetchReportData(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Laporan Penjualan"),
        actions: [
          IconButton(onPressed: _selectDateRange, icon: const Icon(Icons.date_range))
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReportLoaded) {
            if (state.data.totalTransactions == 0) {
              return const Center(child: Text("Tidak ada transaksi di rentang ini."));
            }
            return _buildDashboard(state.data);
          }
          if (state is ReportError) {
             return Center(child: Text("Error: ${state.message}"));
          }
          return const Center(child: Text("Pilih rentang tanggal untuk melihat laporan"));
        },
      ),
    );
  }

  Widget _buildDashboard(ReportModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSummaryCard("Total Pendapatan", "Rp ${data.totalRevenue.toInt()}"),
              _buildSummaryCard("Transaksi", "${data.totalTransactions}"),
            ],
          ),
          const SizedBox(height: 20),
          
          const Text("Tren Pendapatan", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: data.revenueTrend.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.amount.toDouble());
                    }).toList(),
                    isCurved: true,
                    color: AppColors.orange,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Text("Menu Terlaris", style: TextStyle(fontWeight: FontWeight.bold)),
          ...(data.topMenus ?? []).map((menu) => ListTile(
            title: Text(menu.name),
            trailing: Text("${menu.count}x"),
          )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}