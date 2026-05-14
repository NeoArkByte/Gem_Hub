class GemstoneModel {
  final int? id;
  final String date;
  final String variety;
  final String color;
  final bool isRough;
  final bool isCut;
  final bool isSold;
  final double buyingWeight;
  final double buyingPrice;
  final double treatmentCost;
  final double recutCost;
  final double otherProcessingCost;
  final String otherProcessingDesc;
  final double finalWeight;
  final double transportCost;
  final double otherCost;
  final String otherCostReason;
  final double targetPrice;
  final double sellingPrice;
  final String? firstImagePath;
  final String? finalImagePath;

  GemstoneModel({
    this.id,
    required this.date,
    required this.variety,
    required this.color,
    required this.isRough,
    required this.isCut,
    this.isSold = false,
    required this.buyingWeight,
    required this.buyingPrice,
    this.treatmentCost = 0.0,
    this.recutCost = 0.0,
    this.otherProcessingCost = 0.0,
    this.otherProcessingDesc = '',
    this.finalWeight = 0.0,
    this.transportCost = 0.0,
    this.otherCost = 0.0,
    this.otherCostReason = '',
    this.targetPrice = 0.0,
    this.sellingPrice = 0.0,
    this.firstImagePath,
    this.finalImagePath,
  });



  double get targetPriceDiff => targetPrice - sellingPrice;
  double get totalFinalExpenses =>
      buyingPrice +
      treatmentCost +
      recutCost +
      otherProcessingCost +
      transportCost +
      otherCost;

  // Profit only exists if sold and selling price is entered
  double get profit =>
      isSold && sellingPrice > 0 ? (sellingPrice - totalFinalExpenses) : 0.0;

  // Margin only exists if sold
  double get profitPercentage => (isSold && totalFinalExpenses > 0)
      ? (profit / totalFinalExpenses) * 100
      : 0.0;
  // copyWith is essential for Riverpod state updates
  GemstoneModel copyWith({
    int? id,
    String? date,
    String? variety,
    String? color,
    bool? isRough,
    bool? isCut,
    bool? isSold,
    double? buyingWeight,
    double? buyingPrice,
    double? treatmentCost,
    double? recutCost,
    double? otherProcessingCost,
    String? otherProcessingDesc,
    double? finalWeight,
    double? transportCost,
    double? otherCost,
    String? otherCostReason,
    double? targetPrice,
    double? sellingPrice,
    String? firstImagePath,
    String? finalImagePath,
  }) {
    return GemstoneModel(
      id: id ?? this.id,
      date: date ?? this.date,
      variety: variety ?? this.variety,
      color: color ?? this.color,
      isRough: isRough ?? this.isRough,
      isCut: isCut ?? this.isCut,
      isSold: isSold ?? this.isSold,
      buyingWeight: buyingWeight ?? this.buyingWeight,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      treatmentCost: treatmentCost ?? this.treatmentCost,
      recutCost: recutCost ?? this.recutCost,
      otherProcessingCost: otherProcessingCost ?? this.otherProcessingCost,
      otherProcessingDesc: otherProcessingDesc ?? this.otherProcessingDesc,
      finalWeight: finalWeight ?? this.finalWeight,
      transportCost: transportCost ?? this.transportCost,
      otherCost: otherCost ?? this.otherCost,
      otherCostReason: otherCostReason ?? this.otherCostReason,
      targetPrice: targetPrice ?? this.targetPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      firstImagePath: firstImagePath ?? this.firstImagePath,
      finalImagePath: finalImagePath ?? this.finalImagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'variety': variety,
      'color': color,
      'is_rough': isRough ? 1 : 0,
      'is_cut': isCut ? 1 : 0,
      'is_sold': isSold ? 1 : 0,
      'buying_weight': buyingWeight,
      'buying_price': buyingPrice,
      'treatment_cost': treatmentCost,
      'recut_cost': recutCost,
      'other_processing_cost': otherProcessingCost,
      'other_processing_desc': otherProcessingDesc,
      'final_weight': finalWeight,
      'transport_cost': transportCost,
      'other_cost': otherCost,
      'other_cost_reason': otherCostReason,
      'target_price': targetPrice,
      'selling_price': sellingPrice,
      'first_image_path': firstImagePath,
      'final_image_path': finalImagePath,
    };
  }

  factory GemstoneModel.fromMap(Map<String, dynamic> map) {
    return GemstoneModel(
      id: map['id'],
      date: map['date'] ?? '',
      variety: map['variety'] ?? '',
      color: map['color'] ?? '',
      isRough: map['is_rough'] == 1,
      isCut: map['is_cut'] == 1,
      isSold: map['is_sold'] == 1,
      // Using .toDouble() + ?? 0.0 to prevent type mismatch errors from SQLite
      buyingWeight: (map['buying_weight'] as num?)?.toDouble() ?? 0.0,
      buyingPrice: (map['buying_price'] as num?)?.toDouble() ?? 0.0,
      treatmentCost: (map['treatment_cost'] as num?)?.toDouble() ?? 0.0,
      recutCost: (map['recut_cost'] as num?)?.toDouble() ?? 0.0,
      otherProcessingCost:
          (map['other_processing_cost'] as num?)?.toDouble() ?? 0.0,
      otherProcessingDesc: map['other_processing_desc'] ?? '',
      finalWeight: (map['final_weight'] as num?)?.toDouble() ?? 0.0,
      transportCost: (map['transport_cost'] as num?)?.toDouble() ?? 0.0,
      otherCost: (map['other_cost'] as num?)?.toDouble() ?? 0.0,
      otherCostReason: map['other_cost_reason'] ?? '',
      targetPrice: (map['target_price'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (map['selling_price'] as num?)?.toDouble() ?? 0.0,
      firstImagePath: map['first_image_path'],
      finalImagePath: map['final_image_path'],
    );
  }
}
