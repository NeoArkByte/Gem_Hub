import 'package:gemhub/core/enums/user_role.dart';
import 'package:gemhub/data/models/auth/profile_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/repositories/auth/auth_repository_provider.dart';
import 'package:gemhub/data/models/auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'session_provider.g.dart';

@riverpod
Stream<AuthenticatedUser?> session(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  final prefs = await SharedPreferences.getInstance();

  await for (final data in repo.authState) {
    final user = data.session?.user;
    if (user == null) {
      yield null;
      continue;
    }
    

    final cachedRole = prefs.getString('user_role');
    if (cachedRole != null) {
      yield AuthenticatedUser(
        supabaseUser: user,
        profile: ProfileUser(role: UserRole.fromString(cachedRole), id: '', profileId: ''),
      );
    }


    // Refresh from Database
    try {
      final profile = await repo.getUserProfile(user.id);
      if (profile != null) {
        await prefs.setString('user_role', profile.role.name);
        yield AuthenticatedUser(supabaseUser: user, profile: profile);
      }
    } catch (_) {
    }
  }
}
