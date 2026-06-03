import 'dart:io';
import 'package:gemhub/data/models/backup/backup_state.dart';
import 'package:gemhub/data/repositories/backup/backup_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';

part 'backup_viewmodel.g.dart';

@riverpod
class BackupViewModel extends _$BackupViewModel {
  @override
  BackupState build() {
    // Automatically read and index any existing on-disk snapshots upon module startup
    Future.microtask(() => refreshAllSnapshots());
    return BackupState.initial();
  }

  /// Indexes on-disk zip records to dynamically update your lists
  Future<void> refreshAllSnapshots() async {
    final repository = ref.read(backupRepositoryProvider);
    final locals = await repository.getLocalSnapshots();

    state = state.copyWith(
      localSnapshots: locals,
      cloudSnapshots: [], // Stays empty for active testing
    );
  }

  /// Triggers a full-screen loading sequence while zipping active local DB structural data
  Future<void> backupAndSyncAll() async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Creating encrypted database snapshot...",
      successMessage: () => null,
      errorMessage: () => null,
    );

    // Minor delay giving the UI thread time to render the loader smoothly
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final repository = ref.read(backupRepositoryProvider);
      final zipFile = await repository.generateBackupZip();

      if (zipFile == null) throw Exception("Local database serialization failed.");

      // Refresh file array mappings
      final updatedLocals = await repository.getLocalSnapshots();

      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        localSnapshots: updatedLocals,
        successMessage: () => "New backup snapshot compiled and added to storage!",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage: () => "Process broken: ${e.toString().replaceAll('Exception:', '')}",
      );
    }
  }

  /// Triggers a full-screen loading sequence while replacing active database bytes with the target archive selection
  Future<void> restoreFromSnapshot(BackupSnapshot snapshot) async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Extracting records from selected historical point...",
      successMessage: () => null,
      errorMessage: () => null,
    );

    // UI visibility delay padding
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final repository = ref.read(backupRepositoryProvider);
      final targetFile = File(snapshot.pathOrUrl);

      if (!await targetFile.exists()) {
        throw Exception("Target archive snapshot is no longer present on device disk storage.");
      }

      final success = await repository.restoreDatabaseFromZip(targetFile);
      
      if (success) {
        state = state.copyWith(
          isLoading: false,
          statusMessage: "",
          successMessage: () => "Database structural values successfully reverted!",
        );
      } else {
        throw Exception("Structural verification of package map failed.");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage: () => "Restoration failed: ${e.toString().replaceAll('Exception:', '')}",
      );
    }
  }

  void clearNotifications() {
    state = state.copyWith(successMessage: () => null, errorMessage: () => null);
  }
}