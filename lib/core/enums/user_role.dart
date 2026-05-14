enum UserRole {
  ADMIN,
  USER;

  static UserRole fromString(String? role) {
    final normalized = role?.toUpperCase();
    if (normalized == 'ADMIN') return UserRole.ADMIN;
    return UserRole.USER;
  }
}
