import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';

class BackupRepository {
  final String _dbName = 'gemcost_inventory_v12_secure.db';
  static const String _vaultFolder = 'media_vault'; // Aligned with MediaVaultService

  BackupRepository();

  /// Returns either the custom folder chosen by the user or falls back to the safe internal sandbox
  Future<Directory> getTargetBackupDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocsDir.path, 'GemHub_Backups');
    final dir = Directory(dbPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Returns the active media asset directory path matching production services
  Future<Directory> getMediaVaultDirectory() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    final vaultPath = p.join(appDocsDir.path, _vaultFolder);
    final dir = Directory(vaultPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Packages BOTH the database file and the media vault folder natively into a consolidated ZIP archive
  Future<File?> generateBackupZip() async {
    try {
      final dbDir = await getDatabasesPath();
      final sourceDbPath = p.join(dbDir, _dbName);
      final sourceFile = File(sourceDbPath);

      final mediaDir = await getMediaVaultDirectory();

      final List<File> filesToZip = [];

      if (await sourceFile.exists()) {
        filesToZip.add(sourceFile);
      } else {
        throw Exception("Database file does not exist on disk.");
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

      final String timestamp = DateTime.now().toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '')
          .replaceAll('T', '_');

      final targetFolder = await getTargetBackupDirectory();
      final zipPath = p.join(targetFolder.path, 'gemhub_backup_$timestamp.zip');
      final zipFile = File(zipPath);

      final String commonRootPath = _calculateCommonAncestor(sourceFile.path, mediaDir.path);

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

  /// Extracts chosen archives over the live database path and restores the media folder natively
  Future<bool> restoreDatabaseFromZip(File zipFile) async {
    try {
      if (!await zipFile.exists()) return false;

      final dbDir = await getDatabasesPath();
      final sourceDbPath = p.join(dbDir, _dbName);
      final mediaDir = await getMediaVaultDirectory();

      // Recalculate common target directory structure
      final String commonRootPath = _calculateCommonAncestor(sourceDbPath, mediaDir.path);
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

      if (p.extension(externalPath).toLowerCase() != '.zip') {
        throw Exception("Selected file is not a valid archive (.zip).");
      }

      final targetFolder = await getTargetBackupDirectory();
      final originalName = p.basename(externalPath);
      
      String targetName = originalName.startsWith('gemhub_backup_') 
          ? originalName 
          : 'gemhub_backup_imported_${DateTime.now().millisecondsSinceEpoch}.zip';

      final localTargetPath = p.join(targetFolder.path, targetName);
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
        final name = p.basename(entity.path);
        if (entity is File && p.extension(entity.path) == '.zip' && name.startsWith('gemhub_backup_')) {
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
    final List<String> segmentsA = p.split(pathA);
    final List<String> segmentsB = p.split(pathB);
    final List<String> commonAncestry = [];

    for (int i = 0; i < segmentsA.length && i < segmentsB.length; i++) {
      if (segmentsA[i] == segmentsB[i]) {
        commonAncestry.add(segmentsA[i]);
      } else {
        break;
      }
    }
    return p.joinAll(commonAncestry);
  }
}