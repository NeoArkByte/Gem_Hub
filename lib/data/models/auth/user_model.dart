class UserModel {
  final int? id;
  final String name;
  final String username;
  final String? password;
  final String? title;       // e.g., "SENIOR GEMOLOGIST"
  final int? itemsCount;     // e.g., 142
  final double? rating;      // e.g., 4.9
  final String? salesCount;  // e.g., "12k"
  final String? memberSince; // e.g., "August 2021"

  UserModel({
    this.id,
    required this.name,
    required this.username,
    this.password,
    this.title,
    this.itemsCount,
    this.rating,
    this.salesCount,
    this.memberSince,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'],
      title: map['title'],
      itemsCount: map['items_count'],
      rating: map['rating']?.toDouble(),
      salesCount: map['sales_count'],
      memberSince: map['member_since'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
      'title': title,
      'items_count': itemsCount,
      'rating': rating,
      'sales_count': salesCount,
      'member_since': memberSince,
    };
  }
}