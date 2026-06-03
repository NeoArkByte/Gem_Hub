import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:archive/archive_io.dart';
// import 'package:supabase_flutter/supabase_flutter.dart'; // Commented out for local testing
import 'package:gemhub/data/models/backup/backup_snapshot.dart';

class BackupRepository {
  // final SupabaseClient _supabase; // Commented out for local testing
  final String _dbName = 'gemcost_inventory_v12_secure.db';
  // final String _bucketName = 'documents'; // Commented out for local testing

  // BackupRepository(this._supabase); // Commented out for local testing
  BackupRepository(); // Simplified constructor for local test runs

  /// Compresses the encrypted database into a uniquely named timestamped .zip archive
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
      if (zipBytes == null) throw Exception("Failed to encode ZIP binary layout.");

      final String timestamp = DateTime.now().toIso8601String()
          .split('.')
          .first
          .replaceAll(':', '')
          .replaceAll('T', '_');

      final tempDir = Directory.systemTemp;
      final zipPath = p.join(tempDir.path, 'gemhub_backup_$timestamp.zip');
      
      final zipFile = File(zipPath);
      await zipFile.writeAsBytes(zipBytes);

      return zipFile;
    } catch (e) {
      print("❌ [BackupRepository] Error archiving database: $e");
      return null;
    }
  }

  /// Uploads a generated local backup zip into a user's remote cloud directory folder
  Future<bool> uploadBackupToCloud(File localZip, String userId) async {
    // Stubbed out for local testing
    print("☁️ [BackupRepository TEST] uploadBackupToCloud skipped (Supabase bypassed)");
    return true; 
  }

  /// Extracts an incoming zip archive file directly over the operational application database
  Future<bool> restoreDatabaseFromZip(File zipFile) async {
    try {
      if (!await zipFile.exists()) return false;

      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      final ArchiveFile? dbArchiveFile = archive.firstWhere(
        (file) => file.name == _dbName,
        orElse: () => throw Exception("No valid vault database file found in this archive."),
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

  /// Downloads a cloud file snapshot back to local system disk space for execution extraction
  Future<File?> downloadCloudBackup(String cloudPath, String name) async {
    // Stubbed out for local testing
    print("☁️ [BackupRepository TEST] downloadCloudBackup skipped (Supabase bypassed)");
    return null;
  }

  /// Scans local temp cache directories for available historical .zip snapshots
  Future<List<BackupSnapshot>> getLocalSnapshots() async {
    try {
      final tempDir = Directory.systemTemp;
      if (!await tempDir.exists()) return [];

      final List<FileSystemEntity> entities = await tempDir.list().toList();
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

  /// Lists all cloud snapshots saved inside a specific user's remote backup directory directory folder
  Future<List<BackupSnapshot>> getCloudSnapshots(String userId) async {
    // Safely returns an empty list so your UI handles the absence of cloud files gracefully
    return [];
  }
}