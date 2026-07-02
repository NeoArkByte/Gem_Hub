import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:gemhub/data/repositories/backup/backup_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';
import 'package:gemhub/data/models/backup/backup_state.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/core/router/app_router.dart';

part 'backup_viewmodel.g.dart';

@riverpod
class BackupViewModel extends _$BackupViewModel {
  @override
  BackupState build() {
    Future.microtask(() => refreshAllSnapshots());
    return BackupState.initial();
  }

  Future<void> refreshAllSnapshots() async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Checking storage for backups...",
    );

    try {
      final repository = ref.read(backupRepositoryProvider);
      final targetFolder = await repository.getTargetBackupDirectory();
      final locals = await repository.getLocalSnapshots();

      state = state.copyWith(
        isLoading: false,
        currentBackupPath: targetFolder.path,
        localSnapshots: locals,
        cloudSnapshots: [],
        successMessage:
            "Backup history updated successfully!", // 🌟 Triggers your CustomToast.showSuccess
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            "Could not read backup storage folder.", // 🌟 Triggers your CustomToast.showError
      );
    }
  }

  Future<void> backupAndSyncAll() async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Creating database snapshot...",
      successMessage: null,
      errorMessage: null,
    );
    try {
      final repository = ref.read(backupRepositoryProvider);
      final zipFile = await repository.generateBackupZip();

      if (zipFile == null) {
        throw Exception("Local database serialization failed.");
      }

      final updatedLocals = await repository.getLocalSnapshots();
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        localSnapshots: updatedLocals,
        successMessage: "New backup snapshot compiled successfully!",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage: "Process broken: $e",
      );
    }
  }

  Future<void> importAndRestoreFromFile() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;

      state = state.copyWith(
        isLoading: true,
        statusMessage: "Reading backup archive...",
        successMessage: null,
        errorMessage: null,
      );

      final repository = ref.read(backupRepositoryProvider);
      final selectedPath = result.files.single.path!;

      final BackupSnapshot? importedSnapshot =
          await repository.importExternalZip(selectedPath);
      if (importedSnapshot == null) {
        throw Exception("Target file contents rejected validation.");
      }

      final targetFile = File(importedSnapshot.pathOrUrl);
      final success = await repository.restoreDatabaseFromZip(targetFile);

      if (success) {
        final updatedLocals = await repository.getLocalSnapshots();
        state = state.copyWith(
          isLoading: false,
          statusMessage: "",
          localSnapshots: updatedLocals,
          successMessage: "External backup point successfully applied!",
        );
      } else {
        throw Exception("Database core engine extraction failure.");
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage: "Import failed: $e",
      );
    }
  }

  Future<void> restoreFromSnapshot(BackupSnapshot snapshot) async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Extracting records from backup...",
      successMessage: null,
      errorMessage: null,
    );
    try {
      final repository = ref.read(backupRepositoryProvider);
      final targetFile = File(snapshot.pathOrUrl);

      if (!await targetFile.exists()) {
        throw Exception(
          "Target file snapshot has been altered or removed from storage.",
        );
      }

      final success = await repository.restoreDatabaseFromZip(targetFile);
      if (success) {
        // 1. Safely pull the root build context via your exported GoRouter key
        final BuildContext? rootContext = rootNavigatorKey.currentContext;

        if (rootContext != null && rootContext.mounted) {
          // 2. Fetch the root container and invalidate stale providers
          final container = ProviderScope.containerOf(rootContext);

          // 🌟 Clear out your core data providers here so they pull fresh from the new DB
          container.invalidate(inventoryRepositoryProvider);

          // Update the state with success info
          state = state.copyWith(
            isLoading: false,
            statusMessage: "",
            successMessage: "Database successfully restored!",
          );

          // 3. Kick the user back to the home route to force clean UI screen bindings
          rootContext.go('/home');
        } else {
          // Fallback state update if context isn't available/mounted
          state = state.copyWith(
            isLoading: false,
            statusMessage: "",
            successMessage: "Database successfully restored!",
          );
        }
      } else {
        throw Exception(
          "Verification sequence rejected system payload mapping.",
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage: "Restoration failed: ${e.toString()}",
      );
    }
  }

  /// Refactored to leverage low-RAM OS native sharing sheets
  /// Refactored to leverage zero-RAM native file dialogues for custom user target picking
  Future<void> exportSnapshotToFileSystem(BackupSnapshot snapshot) async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Preparing file for export...",
      successMessage: null,
      errorMessage: null,
    );

    try {
      final sourceFile = File(snapshot.pathOrUrl);
      if (!await sourceFile.exists()) {
        throw Exception("Source backup snapshot file not found.");
      }

      // 1. Establish file-system options using the raw path reference instead of bytes.
      final String suggestedName = snapshot.name.endsWith('.zip')
          ? snapshot.name
          : '${snapshot.name}.zip';

      final params = SaveFileDialogParams(
        sourceFilePath:
            sourceFile.path, // ✅ Passes path directly to avoid memory crashes
        fileName:
            suggestedName, // Injects standard default fallback naming layout
      );

      // 2. Open the native platform's 'Save As' system interface
      final String? finalExportedPath =
          await FlutterFileDialog.saveFile(params: params);

      // If the user backs out of the window or cancels the destination picker
      if (finalExportedPath == null) {
        state = state.copyWith(isLoading: false, statusMessage: "");
        return;
      }

      print("🎉 Snapshot successfully saved natively to: $finalExportedPath");

      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        successMessage: "Snapshot successfully exported to device storage!",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage:
            "Export failed: ${e.toString().replaceAll('Exception:', '')}",
      );
    }
  }

  Future<void> deleteSnapshot(BackupSnapshot snapshot) async {
    state = state.copyWith(
      isLoading: true,
      statusMessage: "Purging archive file...",
      successMessage: null,
      errorMessage: null,
    );

    try {
      final targetFile = File(snapshot.pathOrUrl);

      if (await targetFile.exists()) {
        await targetFile.delete();
      }

      final filteredLocals =
          state.localSnapshots.where((item) => item.id != snapshot.id).toList();

      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        localSnapshots: filteredLocals,
        successMessage: "Snapshot archive permanently removed from storage.",
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        statusMessage: "",
        errorMessage: "Failed to delete target backup: $e",
      );
    }
  }

  void clearNotifications() {
    state = state.copyWith(successMessage: null, errorMessage: null);
  }
}
