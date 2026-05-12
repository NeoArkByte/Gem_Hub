import 'package:job_market/core/enums/gem_status.dart';

class Gem {
  final String? gemId; 
  final String owner;
  final String name;
  final double? carat;
  final double? price;
  final String? description;
  final String? imageUrl;
  final String? location;
  final String? sellerPhone;
  final String? variety;
  final String? color;
  final String? certificateUrl;
  final GemStatus status;

  Gem({
    this.gemId,
    required this.owner,
    required this.name,
    this.carat,
    this.price,
    this.description,
    this.imageUrl,
    this.location,
    this.sellerPhone,
    this.variety,
    this.color,
    this.certificateUrl,
    this.status = GemStatus.PENDING,
  });

  factory Gem.fromMap(Map<String, dynamic> map) {
    return Gem(
      gemId: map['gem_id'], 
      owner: map['owner'] is Map 
          ? map['owner']['profile'].toString() 
          : map['owner'].toString(),
      name: map['name'] ?? '',
      carat: (map['carat'] as num?)?.toDouble(),
      price: (map['price'] as num?)?.toDouble(),
      description: map['description'],
      imageUrl: map['image_url'],
      location: map['location'],
      sellerPhone: map['seller_phone'],
      variety: map['variety'],
      color: map['color'],
      certificateUrl: map['certificate_url'],
      status: GemStatus.fromString(map['status']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'owner': owner,
      'name': name,
      'carat': carat,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'location': location,
      'seller_phone': sellerPhone,
      'variety': variety,
      'color': color,
      'certificate_url': certificateUrl,
      'status': status.name.toLowerCase(), 
    };
  }
}