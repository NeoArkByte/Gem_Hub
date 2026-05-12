import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/data/repositories/auth/auth_repository_provider.dart';
import 'package:job_market/data/models/auth/auth_state.dart';

part 'session_provider.g.dart';

@riverpod
Stream<AuthenticatedUser?> session(Ref ref) {
  final repo = ref.watch(authRepositoryProvider);

  // This reacts automatically to Supabase auth changes (login/logout/token refresh)
  return repo.authState.asyncMap((data) async {
    final supabaseUser = data.session?.user;
    if (supabaseUser == null) return null;

    try {
      final profile = await repo.getUserProfile(supabaseUser.id);
      return AuthenticatedUser(supabaseUser: supabaseUser, profile: profile);
    } catch (e) {
      // Return user with null profile if DB fetch fails
      return AuthenticatedUser(supabaseUser: supabaseUser, profile: null);
    }
  });
}