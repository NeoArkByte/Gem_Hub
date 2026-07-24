import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';

class BackupService {
  // Hive stores box files as '<boxName>.hive' in the app documents directory
  static const String _hiveBoxFile = 'gemstones.hive';
  static const String _hiveLockFile = 'gemstones.lock';
  static const String _vaultFolder = 'media_vault'; // Aligned with MediaVaultService

  BackupService();

  /// Returns either the custom folder chosen by the user or falls back to the safe internal sandbox
  Future<Directory> getTargetBackupDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final dbPath = '${appDocsDir.path}/GemHub_Backups';
    final dir = Directory(dbPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns the active media asset directory path matching production services
  Future<Directory> getMediaVaultDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final vaultPath = '${appDocsDir.path}/$_vaultFolder';
    final dir = Directory(vaultPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Packages BOTH the Hive box file and the media vault folder into a consolidated ZIP archive
  Future<File?> generateBackupZip() async {
    try {
      final appDocsDir = await getApplicationDocumentsDirectory();
      final sourceDbPath = '${appDocsDir.path}/$_hiveBoxFile';
      final sourceFile = File(sourceDbPath);

      final mediaDir = await getMediaVaultDirectory();

      final List<File> filesToZip = [];

      if (await sourceFile.exists()) {
        filesToZip.add(sourceFile);
        // Also include the lock file if present
        final lockFile = File('${appDocsDir.path}/$_hiveLockFile');
        if (await lockFile.exists()) filesToZip.add(lockFile);
      } else {
        throw Exception("Hive box file does not exist on disk.");
      }

      if (await mediaDir.exists()) {
        final entities = mediaDir.listSync(recursive: true);
        for (var entity in entities) {
          if (entity is File) {
            filesToZip.add(entity);
          }
        }
      }

      if (filesToZip.isEmpty) return null;

      final String timestamp = DateTime.now()
          .toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '')
          .replaceAll('T', '_');

      final targetFolder = await getTargetBackupDirectory();
      final zipPath = '${targetFolder.path}/gemhub_backup_$timestamp.zip';
      final zipFile = File(zipPath);

      final String commonRootPath =
          _calculateCommonAncestor(sourceFile.path, mediaDir.path);

      await ZipFile.createFromFiles(
        sourceDir: Directory(commonRootPath),
        files: filesToZip,
        zipFile: zipFile,
      );

      debugPrint("⚡ [Native Backup] Successfully created archive package: ${zipFile.path}");
      return zipFile;
    } catch (e) { 
      debugPrint("❌ [BackupService] Error archiving database and media assets: $e");
      return null;
    }
  }

  /// Extracts chosen archives over the live Hive box path and restores the media folder.
  ///
  /// Order of operations:
  ///  1. Close + flush the live Hive box so the file lock is released.
  ///  2. Delete the stale .hive / .lock files so extraction isn't blocked.
  ///  3. Extract the zip (restoring gemstones.hive and media_vault contents).
  ///  4. Re-open the box to validate the restored file is readable.
  ///
  /// Returns `true` only when all steps succeed.
  Future<bool> restoreDatabaseFromZip(File zipFile) async {
    final db = DatabaseHelper();
    try {
      if (!await zipFile.exists()) return false;

      final appDocsDir = await getApplicationDocumentsDirectory();
      final sourceDbPath = '${appDocsDir.path}/$_hiveBoxFile';
      final mediaDir = await getMediaVaultDirectory();

      // ── Step 1: Release the file lock so we can overwrite safely ─────────────
      await db.closeBox();
      debugPrint('⚡ [BackupService] Hive box closed — ready for restore.');

      // ── Step 2: Delete stale Hive files so extraction isn't blocked ───────────
      // flutter_archive does not support overwriting; we delete first.
      final staleHive = File(sourceDbPath);
      final staleLock = File('${appDocsDir.path}/$_hiveLockFile');
      if (await staleHive.exists()) await staleHive.delete();
      if (await staleLock.exists()) await staleLock.delete();
      
      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
      }
      debugPrint('⚡ [BackupService] Stale Hive files and media vault removed.');

      // ── Step 3: Extract the archive ───────────────────────────────────────────
      final String commonRootPath =
          _calculateCommonAncestor(sourceDbPath, mediaDir.path);
      final destinationDir = Directory(commonRootPath);

      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
      );
      debugPrint('⚡ [BackupService] Archive extracted to $commonRootPath');

      // ── Step 4: Re-open the box to confirm the restored file is valid ─────────
      await db.reopenBox();
      debugPrint('⚡ [BackupService] Hive box successfully re-opened after restore.');

      return true;
    } catch (e) {
      debugPrint('❌ [BackupService] Restore failed: $e');
      // Attempt a best-effort reopen so the app does not end up with no database
      try {
        await db.reopenBox();
      } catch (_) {}
      return false;
    }
  }

  /// Copies an externally selected file into the active directory path configuration
  Future<BackupSnapshot?> importExternalZip(String externalPath) async {
    try {
      final externalFile = File(externalPath);
      if (!await externalFile.exists()) throw Exception("Selected external file is unreadable.");

      if (!externalPath.toLowerCase().endsWith('.zip')) {
        throw Exception("Selected file is not a valid archive (.zip).");
      }

      final targetFolder = await getTargetBackupDirectory();
      final originalName = externalPath.replaceAll('\\', '/').split('/').last;
      
      String targetName = originalName.startsWith('gemhub_backup_') 
          ? originalName 
          : 'gemhub_backup_imported_${DateTime.now().millisecondsSinceEpoch}.zip';

      final localTargetPath = '${targetFolder.path}/$targetName';
      final localFile = await externalFile.copy(localTargetPath);
      final stat = await localFile.stat();

      return BackupSnapshot(
        name: targetName,
        pathOrUrl: localFile.path,
        createdAt: stat.changed,
        location: SnapshotLocation.local,
        sizeInBytes: stat.size,
      );
    } catch (e) {
      debugPrint("❌ [BackupService] External medium import failed: $e");
      return null;
    }
  }

  /// Fetches available archives sitting inside the current workspace path destination
  Future<List<BackupSnapshot>> getLocalSnapshots() async {
    try {
      final targetFolder = await getTargetBackupDirectory();
      if (!await targetFolder.exists()) return [];

      final List<FileSystemEntity> entities = await targetFolder.list().toList();
      final List<BackupSnapshot> snapshots = [];

      for (var entity in entities) {
        final name = entity.path.replaceAll('\\', '/').split('/').last;
        if (entity is File &&
            entity.path.endsWith('.zip') &&
            entity.path.split('/').last.startsWith('gemhub_backup_')) {
          final stat = await entity.stat();
          snapshots.add(BackupSnapshot(
            name: name,
            pathOrUrl: entity.path,
            createdAt: stat.changed,
            location: SnapshotLocation.local,
            sizeInBytes: stat.size,
          ));
        }
      }
      snapshots.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return snapshots;
    } catch (e) {
      debugPrint("❌ Error fetching local snapshots: $e");
      return [];
    }
  }

  /// Private internal helper to extract the common base platform path layout
  String _calculateCommonAncestor(String pathA, String pathB) {
    // Simple approach: walk up from pathA until we find the common root
    final segmentsA = pathA.replaceAll('\\', '/').split('/');
    final segmentsB = pathB.replaceAll('\\', '/').split('/');
    final List<String> commonAncestry = [];

    for (int i = 0; i < segmentsA.length && i < segmentsB.length; i++) {
      if (segmentsA[i] == segmentsB[i]) {
        commonAncestry.add(segmentsA[i]);
      } else {
        break;
      }
    }
    return commonAncestry.join('/');
  }
}
