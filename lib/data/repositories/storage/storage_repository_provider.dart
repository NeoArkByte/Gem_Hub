import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/core/providers/supabase/supabase_provider.dart';
import 'storage_repository.dart';

part 'storage_repository_provider.g.dart';

@riverpod
StorageRepository storageRepository(Ref ref) {
  final client = ref.watch(supabaseProvider);
  return StorageRepository(client);
}