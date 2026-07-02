import 'dart:convert';
import 'package:gemhub/data/models/inventory/value_addition_model.dart';
import 'package:gemhub/data/models/inventory/certificate_model.dart';

class GemstoneModel {
  final int? id;

  // Step 1 - Basic Info
  final String category;
  final String origin;
  final String visibility;

  // Step 2 - Buying Details
  final String recordDate;
  final String buyingDate;
  final String buyerName;
  final String buyerContact;
  final double buyingWeight;
  final double buyingPrice;

  final String variety;
  final String buyingColor;
  final String finalColor;
  final bool isRough;
  final bool isCut;

  // Step 3 & 6 - Media
  final List<String> firstLookPhotos;
  final String? firstLookVideo;
  final List<String> finalPhotos;
  final String? finalVideo;

  // Step 4 - Value Additions
  final List<ValueAdditionModel> valueAdditions;

  // Step 5 - Final Stage
  final double currentWeight;
  final double finalWeight;
  final String shape;
  final String clarity;
  final String status;
  final double length;
  final double width;
  final double depth;

  // Step 7 - Certificates
  final bool isCertified;
  final List<CertificateModel> certificates;

  // Step 8 - Finance & Sales
  final bool isReadyToSale;
  final bool isSold;
  final double salesTargetPrice;
  final double actualSoldPrice;
  final double otherCost;
  final String otherCostReason;

  // Legacy direct fields to maintain DB backwards compatibility
  final double treatmentCost;
  final double cuttingCost;
  final double recutCost;
  final double heatCost;
  final double transportCost;
  final double certificateFees;
  final double otherProcessingCost;
  final String otherProcessingDesc;

  GemstoneModel({
    this.id,
    this.category = 'Other',
    this.origin = 'Sri Lanka',
    this.visibility = 'Private',
    required this.recordDate,
    required this.buyingDate,
    this.buyerName = '',
    this.buyerContact = '',
    this.buyingWeight = 0.0,
    this.buyingPrice = 0.0,
    this.variety = '',
    this.buyingColor = '',
    this.finalColor = '',
    this.isRough = true,
    this.isCut = false,
    this.firstLookPhotos = const [],
    this.firstLookVideo,
    this.finalPhotos = const [],
    this.finalVideo,
    this.valueAdditions = const [],
    this.currentWeight = 0.0,
    this.finalWeight = 0.0,
    this.shape = '',
    this.clarity = '',
    this.status = '',
    this.length = 0.0,
    this.width = 0.0,
    this.depth = 0.0,
    this.isCertified = false,
    this.certificates = const [],
    this.isReadyToSale = false,
    this.isSold = false,
    this.salesTargetPrice = 0.0,
    this.actualSoldPrice = 0.0,
    this.otherCost = 0.0,
    this.otherCostReason = '',
    this.treatmentCost = 0.0,
    this.cuttingCost = 0.0,
    this.recutCost = 0.0,
    this.heatCost = 0.0,
    this.transportCost = 0.0,
    this.certificateFees = 0.0,
    this.otherProcessingCost = 0.0,
    this.otherProcessingDesc = '',
  });

  double get totalValueAdditionCosts =>
      valueAdditions.fold(0.0, (sum, addition) => sum + addition.cost);

  double get totalCertificateFees =>
      certificates.fold(0.0, (sum, cert) => sum + cert.certificateFees) +
      certificateFees;

  double get totalFinalCost =>
      buyingPrice +
      totalValueAdditionCosts +
      totalCertificateFees +
      otherCost +
      treatmentCost +
      cuttingCost +
      recutCost +
      heatCost +
      transportCost +
      otherProcessingCost;

  double get targetProfit =>
      salesTargetPrice > 0 ? (salesTargetPrice - totalFinalCost) : 0.0;

  double get targetMargin => (salesTargetPrice > 0 && totalFinalCost > 0)
      ? (targetProfit / totalFinalCost) * 100
      : 0.0;

  double get actualProfit =>
      isSold && actualSoldPrice > 0 ? (actualSoldPrice - totalFinalCost) : 0.0;

  double get actualMargin => (isSold && totalFinalCost > 0)
      ? (actualProfit / totalFinalCost) * 100
      : 0.0;

  // Compatibility getters mapping old names to new fields
  String get date => buyingDate.isNotEmpty ? buyingDate : recordDate;
  String get color => finalColor.isNotEmpty ? finalColor : buyingColor;
  double get sellingPrice => actualSoldPrice;
  double get targetPrice => salesTargetPrice;
  double get profit => actualProfit;
  double get profitPercentage => actualMargin;
  double get totalFinalExpenses => totalFinalCost;
  String? get firstImagePath =>
      firstLookPhotos.isNotEmpty ? firstLookPhotos.first : null;
  String? get finalImagePath =>
      finalPhotos.isNotEmpty ? finalPhotos.first : null;
  String? get firstVideoPath => firstLookVideo;
  String? get finalVideoPath => finalVideo;

  GemstoneModel copyWith({
    int? id,
    String? category,
    String? origin,
    String? visibility,
    String? recordDate,
    String? buyingDate,
    String? buyerName,
    String? buyerContact,
    double? buyingWeight,
    double? buyingPrice,
    String? variety,
    String? buyingColor,
    String? finalColor,
    bool? isRough,
    bool? isCut,
    List<String>? firstLookPhotos,
    String? firstLookVideo,
    List<String>? finalPhotos,
    String? finalVideo,
    List<ValueAdditionModel>? valueAdditions,
    double? currentWeight,
    double? finalWeight,
    String? shape,
    String? clarity,
    String? status,
    double? length,
    double? width,
    double? depth,
    bool? isCertified,
    List<CertificateModel>? certificates,
    bool? isReadyToSale,
    bool? isSold,
    double? salesTargetPrice,
    double? actualSoldPrice,
    double? otherCost,
    String? otherCostReason,
    double? treatmentCost,
    double? cuttingCost,
    double? recutCost,
    double? heatCost,
    double? transportCost,
    double? certificateFees,
    double? otherProcessingCost,
    String? otherProcessingDesc,
    // legacy parameters
    String? date,
    String? color,
    double? targetPrice,
    double? sellingPrice,
    String? firstImagePath,
    String? finalImagePath,
  }) {
    return GemstoneModel(
      id: id ?? this.id,
      category: category ?? this.category,
      origin: origin ?? this.origin,
      visibility: visibility ?? this.visibility,
      recordDate: recordDate ?? this.recordDate,
      buyingDate: buyingDate ?? date ?? this.buyingDate,
      buyerName: buyerName ?? this.buyerName,
      buyerContact: buyerContact ?? this.buyerContact,
      buyingWeight: buyingWeight ?? this.buyingWeight,
      buyingPrice: buyingPrice ?? this.buyingPrice,
      variety: variety ?? this.variety,
      buyingColor: buyingColor ?? color ?? this.buyingColor,
      finalColor: finalColor ?? this.finalColor,
      isRough: isRough ?? this.isRough,
      isCut: isCut ?? this.isCut,
      firstLookPhotos: firstLookPhotos ??
          (firstImagePath != null ? [firstImagePath] : this.firstLookPhotos),
      firstLookVideo: firstLookVideo ?? this.firstLookVideo,
      finalPhotos: finalPhotos ??
          (finalImagePath != null ? [finalImagePath] : this.finalPhotos),
      finalVideo: finalVideo ?? this.finalVideo,
      valueAdditions: valueAdditions ?? this.valueAdditions,
      currentWeight: currentWeight ?? this.currentWeight,
      finalWeight: finalWeight ?? this.finalWeight,
      shape: shape ?? this.shape,
      clarity: clarity ?? this.clarity,
      status: status ?? this.status,
      length: length ?? this.length,
      width: width ?? this.width,
      depth: depth ?? this.depth,
      isCertified: isCertified ?? this.isCertified,
      certificates: certificates ?? this.certificates,
      isReadyToSale: isReadyToSale ?? this.isReadyToSale,
      isSold: isSold ?? this.isSold,
      salesTargetPrice:
          salesTargetPrice ?? targetPrice ?? this.salesTargetPrice,
      actualSoldPrice: actualSoldPrice ?? sellingPrice ?? this.actualSoldPrice,
      otherCost: otherCost ?? this.otherCost,
      otherCostReason: otherCostReason ?? this.otherCostReason,
      treatmentCost: treatmentCost ?? this.treatmentCost,
      cuttingCost: cuttingCost ?? this.cuttingCost,
      recutCost: recutCost ?? this.recutCost,
      heatCost: heatCost ?? this.heatCost,
      transportCost: transportCost ?? this.transportCost,
      certificateFees: certificateFees ?? this.certificateFees,
      otherProcessingCost: otherProcessingCost ?? this.otherProcessingCost,
      otherProcessingDesc: otherProcessingDesc ?? this.otherProcessingDesc,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'origin': origin,
      'visibility': visibility,
      'recordDate': recordDate,
      'buyingDate': buyingDate,
      'buyerName': buyerName,
      'buyerContact': buyerContact,
      'variety': variety,
      'buyingColor': buyingColor,
      'finalColor': finalColor,
      'firstLookPhotos': json.encode(firstLookPhotos),
      'firstLookVideo': firstLookVideo,
      'finalPhotos': json.encode(finalPhotos),
      'finalVideo': finalVideo,
      'valueAdditions': json.encode(valueAdditions.map((x) => x.toMap()).toList()),
      'currentWeight': currentWeight,
      'shape': shape,
      'clarity': clarity,
      'status': status,
      'length': length,
      'width': width,
      'depth': depth,
      'isCertified': isCertified ? 1 : 0,
      'certificates': json.encode(certificates.map((x) => x.toMap()).toList()),
      'isReadyToSale': isReadyToSale ? 1 : 0,
      'salesTargetPrice': salesTargetPrice,
      'actualSoldPrice': actualSoldPrice,
      'cuttingCost': cuttingCost,
      'heatCost': heatCost,
      'certificateFees': certificateFees,
      
      // Legacy backwards mapping matching snake_case schema
      'date': buyingDate,
      'color': finalColor.isNotEmpty ? finalColor : buyingColor,
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
      'target_price': salesTargetPrice,
      'selling_price': actualSoldPrice,
      'first_image_path': firstLookPhotos.isNotEmpty ? firstLookPhotos.first : null,
      'final_image_path': finalPhotos.isNotEmpty ? finalPhotos.first : null,
      'first_video_path': firstLookVideo,
      'final_video_path': finalVideo,
    };
  }

  factory GemstoneModel.fromMap(Map<String, dynamic> map) {
    // Helper function for JSON lists
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is String) {
        try {
          return List<String>.from(json.decode(value));
        } catch (_) {
          return [];
        }
      }
      return [];
    }

    return GemstoneModel(
      id: map['id'],
      category: map['category'] ?? 'Other',
      origin: map['origin'] ?? 'Sri Lanka',
      visibility: map['visibility'] ?? 'Private',
      recordDate: map['recordDate'] ?? map['date'] ?? '',
      buyingDate: map['buyingDate'] ?? map['date'] ?? '',
      buyerName: map['buyerName'] ?? '',
      buyerContact: map['buyerContact'] ?? '',
      buyingWeight:
          (map['buyingWeight'] ?? map['buying_weight'] as num?)?.toDouble() ??
              0.0,
      buyingPrice:
          (map['buyingPrice'] ?? map['buying_price'] as num?)?.toDouble() ??
              0.0,
      variety: map['variety'] ?? '',
      buyingColor: map['buyingColor'] ?? map['color'] ?? '',
      finalColor: map['finalColor'] ?? map['color'] ?? '',
      isRough: (map['isRough'] == 1) || (map['is_rough'] == 1),
      isCut: (map['isCut'] == 1) || (map['is_cut'] == 1),
      firstLookPhotos: map['firstLookPhotos'] != null
          ? parseStringList(map['firstLookPhotos'])
          : (map['first_image_path'] != null ? [map['first_image_path']] : []),
      firstLookVideo: map['firstLookVideo'] ?? map['first_video_path'],
      finalPhotos: map['finalPhotos'] != null
          ? parseStringList(map['finalPhotos'])
          : (map['final_image_path'] != null ? [map['final_image_path']] : []),
      finalVideo: map['finalVideo'] ?? map['final_video_path'],
      valueAdditions: map['valueAdditions'] != null
          ? List<ValueAdditionModel>.from(
              (json.decode(map['valueAdditions']) as List)
                  .map((x) => ValueAdditionModel.fromMap(x)),
            )
          : [],
      currentWeight: (map['currentWeight'] as num?)?.toDouble() ??
          (map['buying_weight'] as num?)?.toDouble() ??
          0.0,
      finalWeight:
          (map['finalWeight'] ?? map['final_weight'] as num?)?.toDouble() ??
              0.0,
      shape: map['shape'] ?? '',
      clarity: map['clarity'] ?? '',
      status: map['status'] ?? '',
      length: (map['length'] as num?)?.toDouble() ?? 0.0,
      width: (map['width'] as num?)?.toDouble() ?? 0.0,
      depth: (map['depth'] as num?)?.toDouble() ?? 0.0,
      isCertified: map['isCertified'] == 1,
      certificates: map['certificates'] != null
          ? List<CertificateModel>.from(
              (json.decode(map['certificates']) as List)
                  .map((x) => CertificateModel.fromMap(x)),
            )
          : [],
      isReadyToSale: map['isReadyToSale'] == 1,
      isSold: (map['isSold'] == 1) || (map['is_sold'] == 1),
      salesTargetPrice: (map['salesTargetPrice'] ?? map['target_price'] as num?)
              ?.toDouble() ??
          0.0,
      actualSoldPrice: (map['actualSoldPrice'] ?? map['selling_price'] as num?)
              ?.toDouble() ??
          0.0,
      otherCost:
          (map['otherCost'] ?? map['other_cost'] as num?)?.toDouble() ?? 0.0,
      otherCostReason: map['otherCostReason'] ?? map['other_cost_reason'] ?? '',
      treatmentCost:
          (map['treatmentCost'] ?? map['treatment_cost'] as num?)?.toDouble() ??
              0.0,
      cuttingCost: (map['cuttingCost'] as num?)?.toDouble() ?? 0.0,
      recutCost:
          (map['recutCost'] ?? map['recut_cost'] as num?)?.toDouble() ?? 0.0,
      heatCost: (map['heatCost'] as num?)?.toDouble() ?? 0.0,
      transportCost:
          (map['transportCost'] ?? map['transport_cost'] as num?)?.toDouble() ??
              0.0,
      certificateFees: (map['certificateFees'] as num?)?.toDouble() ?? 0.0,
      otherProcessingCost:
          (map['otherProcessingCost'] ?? map['other_processing_cost'] as num?)
                  ?.toDouble() ??
              0.0,
      otherProcessingDesc:
          map['otherProcessingDesc'] ?? map['other_processing_desc'] ?? '',
    );
  }
}
