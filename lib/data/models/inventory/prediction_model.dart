class PredictionModel {
  final String gemType;
  final int matchingRecordCount;
  final double averageProfit;
  final double averageExpenses;
  final double averageSellingPrice;
  final double averageDaysToSell;
  final double profitMarginPercent;
  final double totalInventoryProfit;
  final double monthlyProfit;
  final double monthlyExpense;
  final String bestSellingMonth;
  final String mostProfitableGemType;
  final double expectedExpenses;
  final double expectedSellingPrice;
  final double expectedProfit;
  final double expectedDaysToSell;
  final String confidenceLevel;

  const PredictionModel({
    required this.gemType,
    required this.matchingRecordCount,
    required this.averageProfit,
    required this.averageExpenses,
    required this.averageSellingPrice,
    required this.averageDaysToSell,
    required this.profitMarginPercent,
    required this.totalInventoryProfit,
    required this.monthlyProfit,
    required this.monthlyExpense,
    required this.bestSellingMonth,
    required this.mostProfitableGemType,
    required this.expectedExpenses,
    required this.expectedSellingPrice,
    required this.expectedProfit,
    required this.expectedDaysToSell,
    required this.confidenceLevel,
  });

  factory PredictionModel.empty({required String gemType}) {
    return PredictionModel(
      gemType: gemType,
      matchingRecordCount: 0,
      averageProfit: 0,
      averageExpenses: 0,
      averageSellingPrice: 0,
      averageDaysToSell: 0,
      profitMarginPercent: 0,
      totalInventoryProfit: 0,
      monthlyProfit: 0,
      monthlyExpense: 0,
      bestSellingMonth: 'N/A',
      mostProfitableGemType: gemType,
      expectedExpenses: 0,
      expectedSellingPrice: 0,
      expectedProfit: 0,
      expectedDaysToSell: 0,
      confidenceLevel: 'Low',
    );
  }

  factory PredictionModel.fromMap(Map<String, dynamic> map) {
    return PredictionModel(
      gemType: (map['gemType'] ?? '').toString(),
      matchingRecordCount: (map['matchingRecordCount'] as num?)?.toInt() ?? 0,
      averageProfit: (map['averageProfit'] as num?)?.toDouble() ?? 0.0,
      averageExpenses: (map['averageExpenses'] as num?)?.toDouble() ?? 0.0,
      averageSellingPrice:
          (map['averageSellingPrice'] as num?)?.toDouble() ?? 0.0,
      averageDaysToSell: (map['averageDaysToSell'] as num?)?.toDouble() ?? 0.0,
      profitMarginPercent:
          (map['profitMarginPercent'] as num?)?.toDouble() ?? 0.0,
      totalInventoryProfit:
          (map['totalInventoryProfit'] as num?)?.toDouble() ?? 0.0,
      monthlyProfit: (map['monthlyProfit'] as num?)?.toDouble() ?? 0.0,
      monthlyExpense: (map['monthlyExpense'] as num?)?.toDouble() ?? 0.0,
      bestSellingMonth: (map['bestSellingMonth'] ?? 'N/A').toString(),
      mostProfitableGemType: (map['mostProfitableGemType'] ?? '').toString(),
      expectedExpenses: (map['expectedExpenses'] as num?)?.toDouble() ?? 0.0,
      expectedSellingPrice:
          (map['expectedSellingPrice'] as num?)?.toDouble() ?? 0.0,
      expectedProfit: (map['expectedProfit'] as num?)?.toDouble() ?? 0.0,
      expectedDaysToSell:
          (map['expectedDaysToSell'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (map['confidenceLevel'] ?? 'Low').toString(),
    );
  }
}
