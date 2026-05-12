import 'package:job_market/core/enums/user_role.dart';

class ProfileUser {
  final String id;          // ✅ Changed to String to match UUID
  final String profileId;   // UUID from Supabase Auth
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
    this.username,
    this.phone,
    this.avatarUrl,
    this.description,
    required this.role,
    this.createdAt,
    this.updatedAt,
  });

  // DB → Object
  factory ProfileUser.fromMap(Map<String, dynamic> map) {
    return ProfileUser(
      // ✅ Cast as String. If null, provide empty string.
      id: map['id'] as String? ?? '', 
      
      profileId: map['profile_id'] as String? ?? '',
      
      username: map['username'],
      phone: map['phone'],
      avatarUrl: map['avatar_url'],
      description: map['description'],
      
      // Convert the string from DB to UserRole enum
      role: UserRole.fromString(map['role'] ?? 'USER'),
      
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  // Object → DB
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'username': username,
      'phone': phone,
      'avatar_url': avatarUrl,
      'description': description,
      'role': role.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}