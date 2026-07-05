import 'package:gemhub/core/enums/user_role.dart';

class ProfileUser {
  final String id;
  final String profileId;
  final String? email; 
  final String? username;
  final String? phone;
  final String? avatarUrl;
  final String? description;
  final UserRole role;
  final String? createdAt;
  final String? updatedAt;

  ProfileUser({
    required this.id,
    required this.profileId,
    this.email,
    this.username,
    this.phone,
    this.avatarUrl,
    this.description,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileUser.fromMap(Map<String, dynamic> map) {
    return ProfileUser(
      id: map['id'] as String? ?? '', 
      profileId: map['profile_id'] as String? ?? '',
      email: map['email'] as String?, 
      username: map['username'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      description: map['description'] as String?,
      role: UserRole.fromString(map['role'] ?? 'USER'),
      createdAt: map['created_at'] as String?,
      updatedAt: map['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'email': email, 
      'username': username,
      'phone': phone,
      'avatar_url': avatarUrl,
      'description': description,
      'role': role.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  
  ProfileUser copyWith({
    String? id,
    String? profileId,
    String? email,
    String? username,
    String? phone,
    String? avatarUrl,
    String? description,
    UserRole? role,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProfileUser(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}