import 'package:gemhub/data/models/backup/backup_snapshot.dart';

class BackupState {
  final bool isLoading;
  final String statusMessage;
  final String currentBackupPath;
  final List<BackupSnapshot> localSnapshots;
  final List<BackupSnapshot> cloudSnapshots;
  final String? successMessage; // Unified to plain String?
  final String? errorMessage;   // Unified to plain String?

  const BackupState({
    required this.isLoading,
    required this.statusMessage,
    required this.currentBackupPath,
    required this.localSnapshots,
    required this.cloudSnapshots,
    this.successMessage,
    this.errorMessage,
  });

  factory BackupState.initial() {
    return const BackupState(
      isLoading: false,
      statusMessage: '',
      currentBackupPath: '',
      localSnapshots: [],
      cloudSnapshots: [],
      successMessage: null,
      errorMessage: null,
    );
  }

  BackupState copyWith({
    bool? isLoading,
    String? statusMessage,
    String? currentBackupPath,
    List<BackupSnapshot>? localSnapshots,
    List<BackupSnapshot>? cloudSnapshots,
    String? successMessage,
    String? errorMessage,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
      currentBackupPath: currentBackupPath ?? this.currentBackupPath,
      localSnapshots: localSnapshots ?? this.localSnapshots,
      cloudSnapshots: cloudSnapshots ?? this.cloudSnapshots,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }
}