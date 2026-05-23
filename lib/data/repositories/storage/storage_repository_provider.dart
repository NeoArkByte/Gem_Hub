import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/providers/supabase/supabase_provider.dart';
import 'storage_repository.dart';

part 'storage_repository_provider.g.dart';

@riverpod
StorageRepository storageRepository(Ref ref) {
  final client = ref.watch(supabaseProvider);
  return StorageRepository(client);
}