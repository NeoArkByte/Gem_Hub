import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'media_compression_service.dart'; // Import your compression service

part 'media_vault_service.g.dart';

enum MediaType { image, video }

class MediaVaultService {
  final MediaCompressionService _compressionService;
  static const String _vaultFolder = 'media_vault';

  MediaVaultService(this._compressionService);

  /// Internal helper to guarantee the dedicated vault folder exists on disk
  Future<Directory> _getVaultDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory vaultDir = Directory(p.join(appDocDir.path, _vaultFolder));
    
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  /// ONE-STOP HOP: Compresses a raw file and saves it straight to the vault.
  /// Automatically cleans up temporary cache artifacts before returning.
  Future<File?> compressAndSaveToVault({
    required String rawSourcePath,
    required MediaType type,
    Function(double)? onVideoProgress, // Optional video encoding progress
  }) async {
    File? compressedFile;
    try {
      // 1. Intercept and compress depending on the media type
      if (type == MediaType.video) {
        compressedFile = await _compressionService.compressVideo(
          sourcePath: rawSourcePath,
          onProgress: onVideoProgress,
        );
      } else {
        compressedFile = await _compressionService.compressImage(
          sourcePath: rawSourcePath,
        );
      }

      if (compressedFile == null || !await compressedFile.exists()) {
        print("Vault Error: Compression failed to generate a valid file.");
        return null;
      }

      // 2. Prepare permanent destination
      final Directory vaultDir = await _getVaultDirectory();
      final String fileName = p.basename(compressedFile.path);
      final String destinationPath = p.join(vaultDir.path, fileName);

      // 3. Copy the compressed asset into your permanent unencrypted vault
      final File savedVaultFile = await compressedFile.copy(destinationPath);
      print("Media successfully compressed and vaulted at: ${savedVaultFile.path}");
      
      return savedVaultFile;
    } catch (e) {
      print("Failed to process and vault media: $e");
      return null;
    } finally {
      // 4. AUTOMATIC CLEANUP: Wipe the temporary cache files immediately
      await _compressionService.disposeAndCleanup();
    }
  }

  /// Fetches a specific media file out of the vault by its filename
  Future<File?> getVaultFile(String fileName) async {
    try {
      final Directory vaultDir = await _getVaultDirectory();
      final File file = File(p.join(vaultDir.path, fileName));

      if (await file.exists()) return file;
      return null;
    } catch (e) {
      print("Error fetching file from vault: $e");
      return null;
    }
  }

  /// Permanently deletes an item from the vault filesystem
  Future<bool> deleteFromVault(String fileName) async {
    try {
      final Directory vaultDir = await _getVaultDirectory();
      final File file = File(p.join(vaultDir.path, fileName));

      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print("Error removing item from vault: $e");
      return false;
    }
  }
}

/// --- RIVERPOD GENERATOR ---
@riverpod
MediaVaultService mediaVault(Ref ref) {
  // We read the compression provider and inject it straight into the vault
  final compressionService = ref.watch(mediaCompressionProvider);
  return MediaVaultService(compressionService);
}