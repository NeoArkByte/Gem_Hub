class UserModel {
  final int? id;
  final String name;
  final String username;
  final String? password; // Optional if we don't want to carry it around after login

  UserModel({
    this.id,
    required this.name,
    required this.username,
    this.password,
  });

  // Convert Map to UserModel
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'],
    );
  }

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'password': password,
    };
  }

  // CopyWith for easy modification
  UserModel copyWith({
    int? id,
    String? name,
    String? username,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}
