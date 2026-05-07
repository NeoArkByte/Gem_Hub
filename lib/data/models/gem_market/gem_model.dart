import 'package:job_market/core/enums/gem_status.dart';
import 'package:job_market/core/enums/gem_type.dart';

class Gem {
  final int? id;
  final String ownerId;

  final String name;
  final GemType type;
  final double carat;
  final double price;
  final String description;
  final String color;
  final String clarity;
  final String treatment;
  final String shape;
  final String origin;
  final String location;

  final String imageUrl;
  final String sellerPhone;

  final String? videoUrl;

  final GemStatus status;
  final String? createdAt;

  Gem({
    this.id,
    required this.ownerId,
    required this.name,
    required this.type,
    required this.carat,
    required this.price,
    required this.description,
    required this.color,
    required this.clarity,
    required this.treatment,
    required this.shape,
    required this.origin,
    required this.location,
    required this.imageUrl,
    required this.sellerPhone,
    this.videoUrl,
    required this.status,
    this.createdAt,
  });

  // DB → Object
  factory Gem.fromMap(Map<String, dynamic> map) {
    return Gem(
      id: map['id'],
      ownerId: map['owner_id'] ?? '',
      name: map['name'] ?? '',
      type: GemType.fromString(map['type'] ?? 'Other'),
      carat: (map['carat'] as num?)?.toDouble() ?? 0.0,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      color: map['color'] ?? '',
      clarity: map['clarity'] ?? '',
      treatment: map['treatment'] ?? '',
      shape: map['shape'] ?? '',
      origin: map['origin'] ?? '',
      location: map['location'] ?? '',
      imageUrl: map['image_url'] ?? '',
      sellerPhone: map['seller_phone'] ?? '',
      videoUrl: map['video_url'],
      status: GemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GemStatus.active,
      ),
      createdAt: map['created_at'],
    );
  }

  // Object → DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'type': type.displayName,
      'carat': carat,
      'price': price,
      'description': description,
      'color': color,
      'clarity': clarity,
      'treatment': treatment,
      'shape': shape,
      'origin': origin,
      'location': location,
      'image_url': imageUrl,
      'seller_phone': sellerPhone,
      'video_url': videoUrl,
      'status': status.name,
      'created_at': createdAt,
    };
  }
}
