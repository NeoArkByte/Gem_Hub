import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/providers/supabase/supabase_provider.dart';

part 'supabase_token_provider.g.dart';

@riverpod
Stream<String?> accessTokenStream(Ref ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.onAuthStateChange.map((data) => data.session?.accessToken);
}

@riverpod
String? currentAccessToken(Ref ref) {
  // We watch the stream provider and take its latest value
  final authAsync = ref.watch(accessTokenStreamProvider);
  return authAsync.value;
}