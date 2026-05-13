enum UserRole {
  ADMIN,
  USER;

  static UserRole fromString(String? role) {
    final normalized = role?.toUpperCase(); // Handles 'admin', 'Admin', 'ADMIN'
    if (normalized == 'ADMIN') return UserRole.ADMIN;
    return UserRole.USER;
  }
}
