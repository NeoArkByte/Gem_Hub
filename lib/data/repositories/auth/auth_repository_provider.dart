import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/core/providers/supabase/supabase_provider.dart';
import 'auth_repository.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final client = ref.read(supabaseProvider);
  return AuthRepository(client);
}