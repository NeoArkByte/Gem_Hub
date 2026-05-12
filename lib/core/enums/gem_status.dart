enum GemStatus {
  PENDING,
  APPROVED,
  REJECTED;

  static GemStatus fromString(String? status) {
    // Django stores as lowercase 'pending', 'approved', 'rejected'
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

  // Helper to send the value back to Django in the format it expects
  String toDjangoString() => name.toLowerCase();
}