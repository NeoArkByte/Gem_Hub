// lib/data/models/analytics/analytics_data_model.dart

class BusinessSummary {
  final double totalProfit;
  final double totalExpenses;
  final double totalRevenue;
  final int totalInventorySold;
  final double averageProfit;
  final double averageSellingTime;

  BusinessSummary({
    required this.totalProfit,
    required this.totalExpenses,
    required this.totalRevenue,
    required this.totalInventorySold,
    required this.averageProfit,
    required this.averageSellingTime,
  });
}

class MonthlyPerformance {
  final String month; // e.g., '2026-01'
  final double revenue;
  final double expenses;
  final double profit;

  MonthlyPerformance({
    required this.month,
    required this.revenue,
    required this.expenses,
    required this.profit,
  });
}

class GemTypePerformance {
  final String gemType;
  final double averageProfit;
  final double totalSales;
  final double totalRevenue;
  final double averageSellingTime;

  GemTypePerformance({
    required this.gemType,
    required this.averageProfit,
    required this.totalSales,
    required this.totalRevenue,
    required this.averageSellingTime,
  });
}
