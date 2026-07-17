import 'package:flutter_test/flutter_test.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';
import 'package:gemhub/data/services/prediction_service.dart';

class FakePredictionRepository extends InventoryRepository {
  FakePredictionRepository({required this.snapshot});

  final PredictionModel snapshot;
  String? lastGemType;
  String? lastCategory;
  String? lastOrigin;
  double? lastPurchasePrice;
  double? lastWeight;
  String? lastColor;
  String? lastClarity;

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
    lastGemType = gemType;
    lastCategory = category;
    lastOrigin = origin;
    lastPurchasePrice = purchasePrice;
    lastWeight = weight;
    lastColor = color;
    lastClarity = clarity;
    return snapshot;
  }
}

void main() {
  group('PredictionService', () {
    test('maps historical data to expected values and medium confidence',
        () async {
      final service = PredictionService(
        FakePredictionRepository(
          snapshot: PredictionModel(
            gemType: 'Sapphire',
            matchingRecordCount: 12,
            averageProfit: 15000,
            averageExpenses: 40000,
            averageSellingPrice: 55000,
            averageDaysToSell: 21,
            profitMarginPercent: 37.5,
            totalInventoryProfit: 180000,
            monthlyProfit: 22000,
            monthlyExpense: 30000,
            bestSellingMonth: '2026-06',
            mostProfitableGemType: 'Sapphire',
            expectedExpenses: 40000,
            expectedSellingPrice: 55000,
            expectedProfit: 15000,
            expectedDaysToSell: 21,
            confidenceLevel: 'Medium',
          ),
        ),
      );

      final result = await service.predict(gemType: 'Sapphire');

      expect(result.expectedProfit, 15000);
      expect(result.expectedSellingPrice, 55000);
      expect(result.confidenceLevel, 'Medium');
      expect(result.matchingRecordCount, 12);
    });

    test('uses low confidence for very few matching records', () async {
      final service = PredictionService(
        FakePredictionRepository(
          snapshot: PredictionModel(
            gemType: 'Ruby',
            matchingRecordCount: 3,
            averageProfit: 9000,
            averageExpenses: 35000,
            averageSellingPrice: 44000,
            averageDaysToSell: 14,
            profitMarginPercent: 25.7,
            totalInventoryProfit: 27000,
            monthlyProfit: 9000,
            monthlyExpense: 12000,
            bestSellingMonth: '2026-04',
            mostProfitableGemType: 'Ruby',
            expectedExpenses: 35000,
            expectedSellingPrice: 44000,
            expectedProfit: 9000,
            expectedDaysToSell: 14,
            confidenceLevel: 'Low',
          ),
        ),
      );

      final result = await service.predict(gemType: 'Ruby');

      expect(result.confidenceLevel, 'Low');
      expect(result.expectedProfit, 9000);
    });

    test('forwards purchase and quality details to the repository', () async {
      final repository = FakePredictionRepository(
        snapshot: PredictionModel.empty(gemType: 'Sapphire'),
      );
      final service = PredictionService(repository);

      await service.predict(
        gemType: 'Sapphire',
        purchasePrice: 120000,
        weight: 3.5,
        color: 'Blue',
        clarity: 'VVS1',
      );

      expect(repository.lastGemType, 'Sapphire');
      expect(repository.lastPurchasePrice, 120000);
      expect(repository.lastWeight, 3.5);
      expect(repository.lastColor, 'Blue');
      expect(repository.lastClarity, 'VVS1');
    });
  });
}
