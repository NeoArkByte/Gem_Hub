import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';
import 'package:gemhub/data/services/prediction_service.dart';

final predictionViewModelProvider = Provider<PredictionViewModel>((ref) {
  return PredictionViewModel();
});

class PredictionViewModel {
  PredictionViewModel([PredictionService? service])
      : _service = service ?? PredictionService();

  final PredictionService _service;

  Future<PredictionModel> loadPrediction({
    required String gemType,
    String? category,
    String? origin,
    double? purchasePrice,
    double? weight,
    String? color,
    String? clarity,
  }) async {
    return _service.predict(
      gemType: gemType,
      category: category,
      origin: origin,
      purchasePrice: purchasePrice,
      weight: weight,
      color: color,
      clarity: clarity,
    );
  }
}
