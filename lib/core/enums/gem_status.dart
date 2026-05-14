enum GemStatus {
  PENDING,
  APPROVED,
  REJECTED;

  static GemStatus fromString(String? status) {
    final normalized = status?.toUpperCase();
    
    switch (normalized) {
      case 'APPROVED':
        return GemStatus.APPROVED;
      case 'REJECTED':
        return GemStatus.REJECTED;
      case 'PENDING':
      default:
        return GemStatus.PENDING;
    }
  }

  String toDjangoString() => name.toLowerCase();
}