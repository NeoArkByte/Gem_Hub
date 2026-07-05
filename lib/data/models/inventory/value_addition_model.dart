import 'dart:convert';
import 'package:gemhub/core/enums/inventory_enums.dart';

class ValueAdditionModel {
  final CostType costType;
  final String treatmentName;
  final String reason;
  final double cost;
  final double currentWeight;
  final String? photoPath;
  final String? videoPath;

  ValueAdditionModel({
    required this.costType,
    this.treatmentName = '',
    this.reason = '',
    required this.cost,
    required this.currentWeight,
    this.photoPath,
    this.videoPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'costType': costType.name,
      'treatmentName': treatmentName,
      'reason': reason,
      'cost': cost,
      'currentWeight': currentWeight,
      'photoPath': photoPath,
      'videoPath': videoPath,
    };
  }

  factory ValueAdditionModel.fromMap(Map<String, dynamic> map) {
    return ValueAdditionModel(
      costType: CostType.values.firstWhere(
        (e) => e.name == map['costType'],
        orElse: () => CostType.other,
      ),
      treatmentName: map['treatmentName'] ?? '',
      reason: map['reason'] ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ?? 0.0,
      photoPath: map['photoPath'],
      videoPath: map['videoPath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ValueAdditionModel.fromJson(String source) =>
      ValueAdditionModel.fromMap(json.decode(source));
}
