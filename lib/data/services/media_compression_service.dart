import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:v_video_compressor/v_video_compressor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'media_compression_service.g.dart';

class MediaCompressionService {
  final VVideoCompressor _videoCompressor = VVideoCompressor();
  Future<void> _queueLock = Future.value();

  Future<T> _enqueue<T>(Future<T> Function() task) {
    final taskFuture = Completer<T>();

    _queueLock = _queueLock.then((_) async {
      try {
        taskFuture.complete(await task());
      } catch (e, st) {
        taskFuture.completeError(e, st);
      }
    });

    return taskFuture.future;
  }

  Future<File?> compressVideo({
    required String sourcePath,
    Function(double)? onProgress,
  }) =>
      _enqueue(() async {
        final VVideoCompressionResult? result =
            await _videoCompressor.compressVideo(
          sourcePath,
          VVideoCompressionConfig(
            quality: VVideoCompressQuality.medium,
            advanced: VVideoAdvancedConfig(
              autoCorrectOrientation: true,
              videoBitrate: 1800000,
              audioBitrate: 128000,
            ),
          ),
          onProgress: onProgress,
        );

        if (result != null && result.compressedFilePath.isNotEmpty) {
          return File(result.compressedFilePath);
        }
        return null;
      });

  Future<File?> compressImage({
    required String sourcePath,
    int quality = 80,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) =>
      _enqueue(() async {
        final Directory tempDir = await getTemporaryDirectory();
        final String targetPath =
            '${tempDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';

        final XFile? compressedXFile =
            await FlutterImageCompress.compressAndGetFile(
          sourcePath,
          targetPath,
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
          format: CompressFormat.jpeg,
        );

        if (compressedXFile != null) {
          return File(compressedXFile.path);
        }
        return null;
      });
}

// Keep it as a standard auto-dispose provider. No arrays to clear = no race conditions!
@riverpod
MediaCompressionService mediaCompression(Ref ref) {
  return MediaCompressionService();
}