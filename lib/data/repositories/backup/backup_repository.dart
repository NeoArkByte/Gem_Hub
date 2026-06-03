import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gemhub/data/models/backup/backup_snapshot.dart';

class BackupRepository {
  final String _dbName = 'gemcost_inventory_v12_secure.db';
  final String _prefKey = 'custom_backup_directory_path';

  BackupRepository();

  /// Returns either the custom folder chosen by the user or falls back to the safe internal sandbox
  Future<Directory> getTargetBackupDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customPath = prefs.getString(_prefKey);

    if (customPath != null && customPath.isNotEmpty) {
      final customDir = Directory(customPath);
      if (await customDir.exists()) {
        return customDir;
      }
    }

    final appDocsDir = await getApplicationDocumentsDirectory();
    final defaultPath = p.join(appDocsDir.path, 'GemHub_Backups');
    final defaultDir = Directory(defaultPath);

    if (!await defaultDir.exists()) {
      await defaultDir.create(recursive: true);
    }
    return defaultDir;
  }

  Future<void> saveCustomDirectoryPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, path);
  }

  Future<void> clearCustomDirectoryPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  /// Packages the database binary straight into a compressed ZIP file archive inside the active path
  Future<File?> generateBackupZip() async {
    try {
      final dbDir = await getDatabasesPath();
      final sourceDbPath = p.join(dbDir, _dbName);
      final sourceFile = File(sourceDbPath);

      if (!await sourceFile.exists()) {
        throw Exception("Database file does not exist on disk.");
      }

      final dbBytes = await sourceFile.readAsBytes();
      final archive = Archive();
      final archiveFile = ArchiveFile(_dbName, dbBytes.length, dbBytes);
      archive.addFile(archiveFile);

      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes == null) throw Exception("Failed to encode ZIP file structure.");

      final String timestamp = DateTime.now().toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '')
          .replaceAll('T', '_');

      final targetFolder = await getTargetBackupDirectory();
      final zipPath = p.join(targetFolder.path, 'gemhub_backup_$timestamp.zip');
      
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes);

      return zipFile;
    } catch (e) {
      print("❌ [BackupRepository] Error archiving database: $e");
      return null;
    }
  }

  /// Extracts chosen archives over the live database path
  Future<bool> restoreDatabaseFromZip(File zipFile) async {
    try {
      if (!await zipFile.exists()) return false;

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final ArchiveFile? dbArchiveFile = archive.firstWhere(
        (file) => file.name == _dbName,
        orElse: () => throw Exception("No valid backup file found inside this zip."),
      );

      if (dbArchiveFile != null) {
        final dbDir = await getDatabasesPath();
        final targetDbPath = p.join(dbDir, _dbName);

        final targetFile = File(targetDbPath);
        await targetFile.writeAsBytes(dbArchiveFile.content as List<int>);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ [BackupRepository] Error extracting archive: $e");
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
}