import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:v_video_compressor/v_video_compressor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Generates the required type wireframes
part 'media_compression_service.g.dart';

/// A unified media compression class running native underlying platform pipelines.
/// Tracks generated artifacts and safely flushes them on disposal.
class MediaCompressionService {
  final VVideoCompressor _videoCompressor = VVideoCompressor();
  
  // Tracks path addresses of generated temporary cache items for automatic cleanup
  final List<String> _trackedCacheFiles = [];

  /// Compresses and downsizes VIDEOS natively using verified v_video_compressor APIs.
  /// Yields progress via an inline callback supplying values from 0.0 to 1.0.
  Future<File?> compressVideo({
    required String sourcePath,
    VVideoCompressionConfig config = const VVideoCompressionConfig.medium(),
    Function(double)? onProgress,
  }) async {
    try {
      final VVideoCompressionResult? result = await _videoCompressor.compressVideo(
        sourcePath,
        config,
        onProgress: onProgress != null 
            ? (progress) => onProgress(progress) 
            : null,
      );

      if (result != null && result.compressedFilePath.isNotEmpty) {
        _trackedCacheFiles.add(result.compressedFilePath);
        return File(result.compressedFilePath);
      }

      return null;
    } catch (e) {
      print("Error compressing video natively: $e");
      return null;
    }
  }

  /// Compresses and downsizes IMAGES natively using flutter_image_compress
  Future<File?> compressImage({
    required String sourcePath,
    int quality = 80,
    int minWidth = 1920,  
    int minHeight = 1080, 
  }) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String targetPath = '${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedXFile != null) {
        _trackedCacheFiles.add(compressedXFile.path);
        return File(compressedXFile.path);
      }
      return null;
    } catch (e) {
      print("Error compressing image natively: $e");
      return null;
    }
  }

  /// Iterates and purges all local storage artifacts allocated during compression
  Future<void> disposeAndCleanup() async {
    print("Initiating automated cache clear for compression pipelines...");
    for (String path in List.from(_trackedCacheFiles)) {
      try {
        final File file = File(path);
        if (await file.exists()) {
          await file.delete();
          print("Flushed temporary compressed file asset: $path");
        }
      } catch (e) {
        print("Could not strip temporary file address at $path: $e");
      }
    }
    _trackedCacheFiles.clear();
  }
}

/// --- RIVERPOD GENERATOR ---
/// Declares the auto-scoping provider tracking your service lifetime
@riverpod
MediaCompressionService mediaCompression(Ref ref) {
  final MediaCompressionService service = MediaCompressionService();

  // Riverpod lifecycle hook handles automated destruction of temporary disk files 
  // when widgets leave view, or provider instances reset.
  ref.onDispose(() async {
    await service.disposeAndCleanup();
  });

  return service;
}