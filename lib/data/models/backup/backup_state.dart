import 'backup_snapshot.dart';

class BackupState {
  final bool isLoading;
  final String statusMessage;
  final List<BackupSnapshot> localSnapshots;
  final List<BackupSnapshot> cloudSnapshots;
  final String? successMessage;
  final String? errorMessage;

  BackupState({
    required this.isLoading,
    required this.statusMessage,
    required this.localSnapshots,
    required this.cloudSnapshots,
    this.successMessage,
    this.errorMessage,
  });

  factory BackupState.initial() {
    return BackupState(
      isLoading: false,
      statusMessage: "",
      localSnapshots: [],
      cloudSnapshots: [],
      successMessage: null,
      errorMessage: null,
    );
  }

  BackupState copyWith({
    bool? isLoading,
    String? statusMessage,
    List<BackupSnapshot>? localSnapshots,
    List<BackupSnapshot>? cloudSnapshots,
    String? Function()? successMessage,
    String? Function()? errorMessage,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
      localSnapshots: localSnapshots ?? this.localSnapshots,
      cloudSnapshots: cloudSnapshots ?? this.cloudSnapshots,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}