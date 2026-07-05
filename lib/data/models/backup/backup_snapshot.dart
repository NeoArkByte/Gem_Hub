enum SnapshotLocation { local, cloud }

class BackupSnapshot {
  final String id;
  final String name;
  final String pathOrUrl;
  final DateTime createdAt;
  final int sizeInBytes;
  final SnapshotLocation location;

  BackupSnapshot({
    String? id,
    required this.name,
    required this.pathOrUrl,
    required this.createdAt,
    required this.sizeInBytes,
    required this.location,
  }) : id = id ?? name;

  String get formattedSize {
    if (sizeInBytes <= 0) return "0 B";
    if (sizeInBytes < 1024) return "$sizeInBytes B";
    if (sizeInBytes < 1024 * 1024) return "${(sizeInBytes / 1024).toStringAsFixed(1)} KB";
    return "${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  String get formattedTimestamp {
    final String month = createdAt.month.toString().padLeft(2, '0');
    final String day = createdAt.day.toString().padLeft(2, '0');
    final String hour = createdAt.hour.toString().padLeft(2, '0');
    final String minute = createdAt.minute.toString().padLeft(2, '0');
    return "${createdAt.year}-$month-$day $hour:$minute";
  }

  BackupSnapshot copyWith({
    String? id,
    String? name,
    String? pathOrUrl,
    DateTime? createdAt,
    int? sizeInBytes,
    SnapshotLocation? location,
  }) {
    return BackupSnapshot(
      id: id ?? this.id,
      name: name ?? this.name,
      pathOrUrl: pathOrUrl ?? this.pathOrUrl,
      createdAt: createdAt ?? this.createdAt,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      location: location ?? this.location,
    );
  }
}