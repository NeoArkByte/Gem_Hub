// lib/data/repositories/inventory/inventory_repository.dart
import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_repository.g.dart';

class InventoryRepository {
  final DatabaseHelper _db;

  InventoryRepository([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  Future<List<GemstoneModel>> fetchGemstones() => _db.getAllGemstones();

  Future<int> insertGemstone(GemstoneModel gem) => _db.insertGemstone(gem);

  Future<void> deleteGemstone(int id) => _db.deleteGemstone(id);

  Future<void> updateGemstone(GemstoneModel gem) => _db.updateGemstone(gem);

  Future<List<String>> getGemVarieties() => _db.getGemVarieties();

  Future<PredictionModel> getPrediction({
    required String gemType,
    String? category,
    String? origin,
    double? purchasePrice,
    double? weight,
    String? color,
    String? clarity,
  }) =>
      _db.getPrediction(
        gemType: gemType,
        category: category,
        origin: origin,
        purchasePrice: purchasePrice,
        weight: weight,
        color: color,
        clarity: clarity,
      );

  Future<BusinessSummary> getBusinessSummary({String? gemVariety}) =>
      _db.getBusinessSummary(gemVariety: gemVariety);

  Future<List<MonthlyPerformance>> getMonthlyPerformance() =>
      _db.getMonthlyPerformance();

  Future<List<GemTypePerformance>> getTopPerformingGems() =>
      _db.getTopPerformingGems();
}

@riverpod
InventoryRepository inventoryRepository(Ref ref) {
  return InventoryRepository();
}
