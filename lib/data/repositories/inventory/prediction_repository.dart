// lib/data/repositories/inventory/prediction_repository.dart
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
  final DatabaseHelper _db;

  PredictionRepository([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  @override
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
}
