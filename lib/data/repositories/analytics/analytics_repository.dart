// lib/data/repositories/analytics/analytics_repository.dart
import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';

class AnalyticsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Helper strings to keep SQL queries clean and accurate to your schema
  final String _expensesCalc = '''
    (COALESCE(buying_price, 0) + 
     COALESCE(treatment_cost, 0) + 
     COALESCE(recut_cost, 0) + 
     COALESCE(other_processing_cost, 0) + 
     COALESCE(transport_cost, 0) + 
     COALESCE(other_cost, 0) + 
     COALESCE(cuttingCost, 0) + 
     COALESCE(heatCost, 0) + 
     COALESCE(certificateFees, 0))
  ''';

  final String _revenueCalc = 'COALESCE(actualSoldPrice, selling_price, 0)';

  Future<BusinessSummary> getBusinessSummary({String? gemVariety}) async {
    final db = await _dbHelper.database;
    String whereClause = "is_sold = 1";
    List<dynamic> whereArgs = [];

    if (gemVariety != null && gemVariety.isNotEmpty) {
      whereClause += " AND variety = ?";
      whereArgs.add(gemVariety);
    }

    final result = await db.rawQuery('''
      SELECT 
        SUM($_revenueCalc - $_expensesCalc) as total_profit,
        SUM($_expensesCalc) as total_expenses,
        SUM($_revenueCalc) as total_revenue,
        COUNT(id) as total_sold,
        AVG($_revenueCalc - $_expensesCalc) as avg_profit,
        -- Note: Proxying selling time using recordDate and buyingDate as date_sold is absent
        AVG(julianday(recordDate) - julianday(buyingDate)) as avg_selling_days 
      FROM gemstones 
      WHERE $whereClause
    ''', whereArgs);

    final row = result.first;
    return BusinessSummary(
      totalProfit: (row['total_profit'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (row['total_expenses'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (row['total_revenue'] as num?)?.toDouble() ?? 0.0,
      totalInventorySold: (row['total_sold'] as int?) ?? 0,
      averageProfit: (row['avg_profit'] as num?)?.toDouble() ?? 0.0,
      averageSellingTime: (row['avg_selling_days'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<List<MonthlyPerformance>> getMonthlyPerformance() async {
    final db = await _dbHelper.database;

    // Grouping by 'date' column assuming it reflects the transaction/record date
    final result = await db.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        SUM($_revenueCalc) as revenue,
        SUM($_expensesCalc) as expenses,
        SUM($_revenueCalc - $_expensesCalc) as profit
      FROM gemstones
      WHERE is_sold = 1 AND date IS NOT NULL
      GROUP BY strftime('%Y-%m', date)
      ORDER BY month ASC
    ''');

    return result
        .map((row) => MonthlyPerformance(
              month: row['month'] as String,
              revenue: (row['revenue'] as num?)?.toDouble() ?? 0.0,
              expenses: (row['expenses'] as num?)?.toDouble() ?? 0.0,
              profit: (row['profit'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();
  }

  Future<List<GemTypePerformance>> getTopPerformingGems() async {
    final db = await _dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        variety,
        AVG($_revenueCalc - $_expensesCalc) as avg_profit,
        COUNT(id) as total_sales,
        SUM($_revenueCalc) as total_revenue,
        AVG(julianday(recordDate) - julianday(buyingDate)) as avg_selling_days
      FROM gemstones
      WHERE is_sold = 1
      GROUP BY variety
      ORDER BY avg_profit DESC
    ''');

    return result
        .map((row) => GemTypePerformance(
              gemType: row['variety'] as String? ?? 'Unknown',
              averageProfit: (row['avg_profit'] as num?)?.toDouble() ?? 0.0,
              totalSales: (row['total_sales'] as num?)?.toDouble() ?? 0.0,
              totalRevenue: (row['total_revenue'] as num?)?.toDouble() ?? 0.0,
              averageSellingTime:
                  (row['avg_selling_days'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();
  }
}
