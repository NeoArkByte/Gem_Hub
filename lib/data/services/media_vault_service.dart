import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'media_compression_service.dart';

enum MediaType { image, video }

class MediaVaultService {
  final MediaCompressionService _compressionService;
  static const String _vaultFolder = 'media_vault';

  MediaVaultService([MediaCompressionService? compressionService])
      : _compressionService = compressionService ?? MediaCompressionService();

  Future<Directory> _getVaultDirectory() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory vaultDir = Directory(p.join(appDocDir.path, _vaultFolder));
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  Future<File?> compressAndSaveToVault({
    required String rawSourcePath,
    required MediaType type,
    Function(double)? onVideoProgress,
  }) async {
    File? compressedFile;
    try {
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
        print("Vault Error: Compression produced no valid output.");
        return null;
      }

      final Directory vaultDir = await _getVaultDirectory();
      final String sourceBaseName = p.basenameWithoutExtension(rawSourcePath);
      final String ext = type == MediaType.video ? 'mp4' : 'jpg';
      final String uniqueName =
          '${sourceBaseName}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final String destinationPath = p.join(vaultDir.path, uniqueName);

      final File savedVaultFile = await compressedFile.copy(destinationPath);
      print("Vaulted media at: ${savedVaultFile.path}");

      return savedVaultFile;
    } catch (e, st) {
      print("Failed to compress and vault media: $e\n$st");
      rethrow;
    } finally {
      // Self-contained atomic cleanup. Fires regardless of success or failure blocks.
      if (compressedFile != null) {
        try {
          if (await compressedFile.exists()) {
            await compressedFile.delete();
            print("Successfully deleted isolated temp cache file.");
          }
        } catch (e) {
          print("Warning: Could not delete temp file ${compressedFile.path}: $e");
        }
      }
    }
  }

  Future<File?> getVaultFile(String fileName) async {
    final Directory vaultDir = await _getVaultDirectory();
    final File file = File(p.join(vaultDir.path, fileName));
    if (await file.exists()) return file;
    return null;
  }

  Future<bool> deleteFromVault(String fileName) async {
    try {
      final Directory vaultDir = await _getVaultDirectory();
      final File file = File(p.join(vaultDir.path, fileName));
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e, st) {
      print("Error deleting vault file: $e\n$st");
      rethrow;
    }
  }
}