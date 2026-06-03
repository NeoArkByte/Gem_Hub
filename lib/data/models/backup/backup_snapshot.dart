enum SnapshotLocation { local, cloud }

class BackupSnapshot {
  final String name;
  final String pathOrUrl;
  final DateTime createdAt;
  final SnapshotLocation location;
  final int? sizeInBytes;

  BackupSnapshot({
    required this.name,
    required this.pathOrUrl,
    required this.createdAt,
    required this.location,
    this.sizeInBytes,
  });

  String get formattedSize {
    if (sizeInBytes == null) return "Unknown size";
    final kb = sizeInBytes! / 1024;
    if (kb < 1024) return "${kb.toStringAsFixed(1)} KB";
    final mb = kb / 1024;
    return "${mb.toStringAsFixed(1)} MB";
  }
}