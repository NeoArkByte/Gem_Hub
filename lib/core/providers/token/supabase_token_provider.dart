import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/core/providers/supabase/supabase_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_token_provider.g.dart';

/// Listens to auth state changes and provides the current access token.
@riverpod
Stream<String?> accessTokenStream(Ref ref) {
  final client = ref.watch(supabaseProvider);
  return client.auth.onAuthStateChange.map((data) => data.session?.accessToken);
}

/// Provides the current access token as a simple string.
/// This is what we will read inside the Dio Interceptor.
@riverpod
String? currentAccessToken(Ref ref) {
  // We watch the stream provider and take its latest value
  final authAsync = ref.watch(accessTokenStreamProvider);
  return authAsync.value;
}