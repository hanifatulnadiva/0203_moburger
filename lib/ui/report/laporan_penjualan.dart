import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:moburger/bloc/report/report_bloc.dart';
import 'package:moburger/core/contants/colors.dart';
import '../../data/models/report_model.dart';
import 'package:moburger/core/service/report_excel_exporter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _currencyFormat = NumberFormat.decimalPattern('id_ID');
  final _dateLabelFormat = DateFormat('dd MMM', 'id_ID');
  final _dateFullFormat = DateFormat('dd MMM yyyy', 'id_ID');

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(FetchTodayReport());
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: DateTime.now().subtract(const Duration(days: 6)),
        end: DateTime.now(),
      ),
    );
    if (picked != null && mounted) {
      context.read<ReportBloc>().add(FetchReportData(picked));
    }
  }

  void _resetToToday() {
    context.read<ReportBloc>().add(FetchTodayReport());
  }

  Future<void> _handleExport(ReportLoaded state) async {
    setState(() => _isExporting = true);
    try {
      await ReportExcelExporter.exportAndShare(
        data: state.summary,
        start: state.activeRange.start,
        end: state.activeRange.end,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat file Excel: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Laporan Penjualan'),
        backgroundColor: AppColors.darkRed,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<ReportBloc, ReportState>(
            builder: (context, state) {
              if (state is! ReportLoaded) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Unduh Excel',
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.file_download_outlined),
                onPressed: _isExporting ? null : () => _handleExport(state),
              );
            },
          ),
          IconButton(
            tooltip: 'Pilih rentang tanggal',
            onPressed: _selectDateRange,
            icon: const Icon(Icons.date_range),
          ),
        ],
      ),
      body: BlocBuilder<ReportBloc, ReportState>(
        builder: (context, state) {
          if (state is ReportLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.orange),
            );
          }
          if (state is ReportLoaded) {
            if (state.summary.totalTransactions == 0 &&
                state.isDefaultView) {
              return _buildEmptyToday(state);
            }
            if (state.summary.totalTransactions == 0) {
              return _buildEmptyRange(state);
            }
            return _buildDashboard(state);
          }
          if (state is ReportError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(
            child: Text('Pilih rentang tanggal untuk melihat laporan'),
          );
        },
      ),
    );
  }

  Widget _buildEmptyToday(ReportLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'Belum ada transaksi hari ini',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            // Tetap tampilkan tren 7 hari meski hari ini masih kosong.
            if (state.trend.revenueTrend.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tren 7 Hari Terakhir',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _buildRevenueBarChart(state.trend.revenueTrend),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyRange(ReportLoaded state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              'Tidak ada transaksi pada\n${_dateFullFormat.format(state.activeRange.start)} - ${_dateFullFormat.format(state.activeRange.end)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resetToToday,
              child: const Text('Kembali ke laporan hari ini'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(ReportLoaded state) {
    final data = state.summary;
    final trendData = state.trend.revenueTrend;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodBanner(state),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryCard(
                'Total Pendapatan',
                'Rp ${_currencyFormat.format(data.totalRevenue)}',
                Icons.payments_outlined,
                AppColors.darkRed,
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                state.isDefaultView ? 'Pesanan Hari Ini' : 'Total Pesanan',
                '${data.totalTransactions}',
                Icons.receipt_long_outlined,
                AppColors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text(
            state.isDefaultView
                ? 'Tren Pendapatan (7 Hari Terakhir)'
                : 'Tren Pendapatan',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          if (trendData.isNotEmpty)
            _buildRevenueBarChart(trendData)
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('Belum ada data tren.')),
            ),

          const SizedBox(height: 28),

          if (data.topMenus.isNotEmpty) ...[
            const Text(
              'Menu Terlaris',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            _buildTopMenuSection(data.topMenus),
          ],

          if (data.topToppings.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              'Topping Terlaris',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 12),
            ...data.topToppings.map(
              (t) => _buildRankRow(t.name, t.count, AppColors.yellow),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildPeriodBanner(ReportLoaded state) {
    final label = state.isDefaultView
        ? 'Hari ini, ${_dateFullFormat.format(state.activeRange.start)}'
        : '${_dateFullFormat.format(state.activeRange.start)} - ${_dateFullFormat.format(state.activeRange.end)}';

    return Row(
      children: [
        Icon(Icons.calendar_today, size: 16, color: AppColors.darkRed),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.darkRed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (!state.isDefaultView)
          TextButton(
            onPressed: _resetToToday,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: const Text('Reset ke Hari Ini'),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: accentColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Bar chart tren pendapatan — dipilih karena lebih mudah dibaca per hari
  /// dibanding line chart, terutama untuk rentang pendek seperti 7 hari.
  Widget _buildRevenueBarChart(List<RevenueData> trend) {
    final maxY = trend.fold<double>(
      0,
      (prev, e) => e.amount > prev ? e.amount : prev,
    );
    // Beri ruang di atas bar tertinggi agar tidak terpotong.
    final chartMaxY = maxY <= 0 ? 10.0 : maxY * 1.2;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          maxY: chartMaxY,
          minY: 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => AppColors.darkRed,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final item = trend[group.x.toInt()];
                return BarTooltipItem(
                  '${_dateLabelFormat.format(item.date)}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Rp ${_currencyFormat.format(item.amount)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= trend.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _dateLabelFormat.format(trend[index].date),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: trend.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.amount,
                  color: AppColors.orange,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Pie chart untuk porsi menu terlaris, dilengkapi legenda di bawahnya.
  Widget _buildTopMenuSection(List<ProductStat> menus) {
    final palette = [
      AppColors.darkRed,
      AppColors.orange,
      AppColors.yellow,
      AppColors.success,
      Colors.grey,
    ];
    final total = menus.fold<int>(0, (sum, m) => sum + m.count);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: menus.asMap().entries.map((e) {
                  final color = palette[e.key % palette.length];
                  final percent = total == 0
                      ? 0
                      : (e.value.count / total * 100);
                  return PieChartSectionData(
                    value: e.value.count.toDouble(),
                    color: color,
                    title: '${percent.toStringAsFixed(0)}%',
                    radius: 48,
                    titleStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...menus.asMap().entries.map((e) {
            final color = palette[e.key % palette.length];
            return _buildRankRow(e.value.name, e.value.count, color);
          }),
        ],
      ),
    );
  }

  Widget _buildRankRow(String name, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, overflow: TextOverflow.ellipsis),
          ),
          Text(
            '${count}x',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}