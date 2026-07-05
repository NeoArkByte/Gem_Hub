import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageRepository {
  final SupabaseClient _client;

  StorageRepository(this._client);


  Future<String> uploadListing(File file, String userId) =>
      _upload(bucket: 'listings', file: file, userId: userId);

  Future<String> uploadAvatar(File file, String userId) =>
      _upload(bucket: 'avatars', file: file, userId: userId);

  Future<String> uploadDocument(File file, String userId) =>
      _upload(bucket: 'documents', file: file, userId: userId);

  Future<String> getTemporaryUrl(String path) async {
    return await _client.storage.from('documents').createSignedUrl(path, 3600);
  }


  Future<String> updateFile({
    required String bucket,
    required File newFile,
    required String userId,
    required String? oldUrlOrPath,
  }) async {
    final newResult = await _upload(bucket: bucket, file: newFile, userId: userId);

    if (oldUrlOrPath != null && oldUrlOrPath.isNotEmpty) {
      await deleteFile(bucket: bucket, urlOrPath: oldUrlOrPath);
    }

    return newResult;
  }


  Future<void> deleteFile({required String bucket, required String urlOrPath}) async {
    try {
      String path = urlOrPath;
      if (urlOrPath.contains('http')) {
        final uri = Uri.parse(urlOrPath);
        final segments = uri.pathSegments;
        final idx = segments.indexOf(bucket);
        if (idx != -1 && idx + 1 < segments.length) {
          path = segments.sublist(idx + 1).join('/');
        }
      }
      await _client.storage.from(bucket).remove([path]);
    } catch (e) {
      debugPrint('StorageRepository: Delete failed (ignoring): $e');
    }
  }


  Future<String> _upload({
    required String bucket,
    required File file,
    required String userId,
  }) async {
    final extension = file.path.split('.').last;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.$extension';
    final path = '$userId/$fileName';

    await _client.storage.from(bucket).upload(path, file);
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}