// lib/data/models/report_model.dart

class ReportModel {
  final double totalRevenue;
  final int totalTransactions;
  final double averageOrderValue;
  final List<RevenueData> revenueTrend;
  final List<HourlyData> peakHours;
  final List<ProductStat> topMenus;
  final List<ProductStat> topToppings;

  ReportModel({
    required this.totalRevenue,
    required this.totalTransactions,
    required this.averageOrderValue,
    required this.revenueTrend,
    required this.peakHours,
    required this.topMenus,
    required this.topToppings,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      totalRevenue: (json['total_revenue'] ?? 0).toDouble(),
      totalTransactions: json['total_transactions'] ?? 0,
      averageOrderValue: (json['avg_order_value'] ?? 0).toDouble(),
      
      // Menggunakan operator '?' dan '?? []' agar aplikasi tahan banting (anti-crash)
      revenueTrend: (json['revenue_trend'] as List?)
          ?.map((i) => RevenueData.fromJson(i))
          .toList() ?? [],
          
      peakHours: (json['peak_hours'] as List?)
          ?.map((i) => HourlyData.fromJson(i))
          .toList() ?? [],
          
      topMenus: (json['top_menus'] as List?)
          ?.map((i) => ProductStat.fromJson(i))
          .toList() ?? [],
          
      topToppings: (json['top_toppings'] as List?)
          ?.map((i) => ProductStat.fromJson(i))
          .toList() ?? [],
    );
  }
}

class RevenueData {
  final DateTime date;
  final double amount;
  RevenueData(this.date, this.amount);
  
  factory RevenueData.fromJson(Map<String, dynamic> json) => RevenueData(
    json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(), 
    (json['amount'] ?? 0).toDouble()
  );
}

class ProductStat {
  final String name;
  final int count;
  ProductStat(this.name, this.count);
  
  factory ProductStat.fromJson(Map<String, dynamic> json) => ProductStat(
    json['name'] ?? 'Unknown', 
    json['count'] ?? 0
  );
}

class HourlyData {
  final int hour;
  final int transactionCount;
  HourlyData(this.hour, this.transactionCount);
  
  factory HourlyData.fromJson(Map<String, dynamic> json) => HourlyData(
    json['hour'] ?? 0, 
    json['count'] ?? 0
  );
}