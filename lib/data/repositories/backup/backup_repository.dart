import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';

class BackupRepository {
  // Hive stores box files as '<boxName>.hive' in the app documents directory
  static const String _hiveBoxFile = 'gemstones.hive';
  static const String _hiveLockFile = 'gemstones.lock';
  static const String _vaultFolder = 'media_vault'; // Aligned with MediaVaultService

  BackupRepository();

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

      print("⚡ [Native Backup] Successfully created archive package: ${zipFile.path}");
      return zipFile;
    } catch (e) { 
      print("❌ [BackupRepository] Error archiving database and media assets: $e");
      return null;
    }
  }

  /// Extracts chosen archives over the live Hive box path and restores the media folder
  Future<bool> restoreDatabaseFromZip(File zipFile) async {
    try {
      if (!await zipFile.exists()) return false;

      final appDocsDir = await getApplicationDocumentsDirectory();
      final sourceDbPath = '${appDocsDir.path}/$_hiveBoxFile';
      final mediaDir = await getMediaVaultDirectory();

      // Recalculate common target directory structure
      final String commonRootPath =
          _calculateCommonAncestor(sourceDbPath, mediaDir.path);
      final destinationDir = Directory(commonRootPath);

      // Native extraction handles creating folders and unpacking assets at hardware speeds
      await ZipFile.extractToDirectory(
        zipFile: zipFile,
        destinationDir: destinationDir,
      );

      print("⚡ [Native Restore] Structural extraction finalized successfully over root sandbox!");
      return true;
    } catch (e) {
      print("❌ [BackupRepository] Error extracting native archive bundle: $e");
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
      print("❌ [BackupRepository] External medium import failed: $e");
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
      print("❌ Error fetching local snapshots: $e");
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