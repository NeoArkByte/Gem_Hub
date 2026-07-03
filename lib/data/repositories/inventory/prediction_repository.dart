import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';

abstract class PredictionRepositoryProtocol {
  Future<PredictionModel> getPrediction({
    required String gemType,
    String? category,
    String? origin,
    double? purchasePrice,
    double? weight,
    String? color,
    String? clarity,
  });
}

class PredictionRepository implements PredictionRepositoryProtocol {
  PredictionRepository([DatabaseHelper? databaseHelper])
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  final DatabaseHelper _databaseHelper;

  @override
  Future<PredictionModel> getPrediction({
    required String gemType,
    String? category,
    String? origin,
    double? purchasePrice,
    double? weight,
    String? color,
    String? clarity,
  }) async {
    final db = await _databaseHelper.database;

    final normalizedGemType = gemType.trim();
    if (normalizedGemType.isEmpty) {
      return PredictionModel.empty(gemType: gemType);
    }

    final whereClauses = <String>[];
    final whereArgs = <Object?>[];

    whereClauses.add("(variety = ? OR category = ?)");
    whereArgs.addAll([normalizedGemType, normalizedGemType]);

    if ((category ?? '').trim().isNotEmpty && category != 'All') {
      whereClauses.add('category = ?');
      whereArgs.add(category);
    }

    if ((origin ?? '').trim().isNotEmpty && origin != 'All') {
      whereClauses.add('origin = ?');
      whereArgs.add(origin);
    }

    if (purchasePrice != null && purchasePrice > 0) {
      final lowerBound = purchasePrice * 0.8;
      final upperBound = purchasePrice * 1.2;
      whereClauses.add('(buying_price BETWEEN ? AND ?)');
      whereArgs.addAll([lowerBound, upperBound]);
    }

    if (weight != null && weight > 0) {
      final lowerBound = weight * 0.8;
      final upperBound = weight * 1.2;
      whereClauses.add('(buying_weight BETWEEN ? AND ?)');
      whereArgs.addAll([lowerBound, upperBound]);
    }

    if ((color ?? '').trim().isNotEmpty) {
      whereClauses.add('(buyingColor = ? OR finalColor = ?)');
      whereArgs.addAll([color, color]);
    }

    if ((clarity ?? '').trim().isNotEmpty) {
      whereClauses.add('(clarity = ?)');
      whereArgs.add(clarity);
    }

    final whereSql = whereClauses.isEmpty ? null : whereClauses.join(' AND ');

    final rows = await db.rawQuery('''
      SELECT
        COUNT(*) AS matchingRecordCount,
        AVG(CASE WHEN actualSoldPrice > 0 THEN (actualSoldPrice - buyingPrice - certificateFees - otherCost) ELSE NULL END) AS averageProfit,
        AVG(CASE WHEN actualSoldPrice > 0 THEN (buyingPrice + certificateFees + otherCost) ELSE NULL END) AS averageExpenses,
        AVG(CASE WHEN actualSoldPrice > 0 THEN actualSoldPrice ELSE NULL END) AS averageSellingPrice,
        AVG(CASE WHEN recordDate IS NOT NULL AND buyingDate IS NOT NULL THEN (julianday(recordDate) - julianday(buyingDate)) ELSE NULL END) AS averageDaysToSell,
        SUM(CASE WHEN actualSoldPrice > 0 THEN (actualSoldPrice - buyingPrice - certificateFees - otherCost) ELSE 0 END) AS totalInventoryProfit,
        (
          SELECT substr(recordDate, 1, 7)
          FROM gemstones
          WHERE is_sold = 1
            AND (${whereSql ?? '1=1'})
          GROUP BY substr(recordDate, 1, 7)
          ORDER BY SUM(CASE WHEN actualSoldPrice > 0 THEN (actualSoldPrice - buyingPrice - certificateFees - otherCost) ELSE 0 END) DESC
          LIMIT 1
        ) AS bestSellingMonth,
        (
          SELECT variety
          FROM gemstones
          WHERE is_sold = 1
            AND (${whereSql ?? '1=1'})
          GROUP BY variety
          ORDER BY SUM(CASE WHEN actualSoldPrice > 0 THEN (actualSoldPrice - buyingPrice - certificateFees - otherCost) ELSE 0 END) DESC
          LIMIT 1
        ) AS mostProfitableGemType
      FROM gemstones
      WHERE is_sold = 1
        AND (${whereSql ?? '1=1'})
    ''', whereArgs);

    final row = rows.isNotEmpty ? rows.first : null;
    final matchingCount = (row?['matchingRecordCount'] as num?)?.toInt() ?? 0;

    if (matchingCount == 0) {
      return PredictionModel.empty(gemType: normalizedGemType);
    }

    final avgProfit = (row?['averageProfit'] as num?)?.toDouble() ?? 0.0;
    final avgExpenses = (row?['averageExpenses'] as num?)?.toDouble() ?? 0.0;
    final avgSellingPrice =
        (row?['averageSellingPrice'] as num?)?.toDouble() ?? 0.0;
    final avgDaysToSell =
        (row?['averageDaysToSell'] as num?)?.toDouble() ?? 0.0;
    final totalProfit =
        (row?['totalInventoryProfit'] as num?)?.toDouble() ?? 0.0;
    final profitMargin = avgSellingPrice > 0
        ? ((avgSellingPrice - avgExpenses) / avgSellingPrice) * 100
        : 0.0;

    final confidence = matchingCount <= 5
        ? 'Low'
        : matchingCount <= 20
            ? 'Medium'
            : 'High';

    return PredictionModel(
      gemType: normalizedGemType,
      matchingRecordCount: matchingCount,
      averageProfit: avgProfit,
      averageExpenses: avgExpenses,
      averageSellingPrice: avgSellingPrice,
      averageDaysToSell: avgDaysToSell,
      profitMarginPercent: profitMargin,
      totalInventoryProfit: totalProfit,
      monthlyProfit: 0.0,
      monthlyExpense: 0.0,
      bestSellingMonth: (row?['bestSellingMonth'] ?? 'N/A').toString(),
      mostProfitableGemType:
          (row?['mostProfitableGemType'] ?? normalizedGemType).toString(),
      expectedExpenses: avgExpenses,
      expectedSellingPrice: avgSellingPrice,
      expectedProfit: avgProfit,
      expectedDaysToSell: avgDaysToSell,
      confidenceLevel: confidence,
    );
  }
}
