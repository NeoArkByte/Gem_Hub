import 'package:gemhub/data/models/inventory/prediction_model.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';

class PredictionService {
  PredictionService([InventoryRepository? repository])
      : _repository = repository ?? InventoryRepository();

  final InventoryRepository _repository;

  Future<PredictionModel> predict({
    required String gemType,
    String? category,
    String? origin,
    double? purchasePrice,
    double? weight,
    String? color,
    String? clarity,
  }) async {
    final prediction = await _repository.getPrediction(
      gemType: gemType,
      category: category,
      origin: origin,
      purchasePrice: purchasePrice,
      weight: weight,
      color: color,
      clarity: clarity,
    );
    return prediction;
  }
}
