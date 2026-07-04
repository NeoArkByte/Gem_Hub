import 'dart:convert';

class CertificateModel {
  final String labName;
  final double certificateFees;
  final List<String> images;

  CertificateModel({
    required this.labName,
    required this.certificateFees,
    required this.images,
  });

  Map<String, dynamic> toMap() {
    return {
      'labName': labName,
      'certificateFees': certificateFees,
      'images': images,
    };
  }

  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    return CertificateModel(
      labName: map['labName'] ?? '',
      certificateFees: (map['certificateFees'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(map['images'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory CertificateModel.fromJson(String source) =>
      CertificateModel.fromMap(json.decode(source));
}
