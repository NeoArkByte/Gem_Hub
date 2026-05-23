import 'package:job_market/features/auth/provider/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:job_market/data/models/auth/auth_state.dart'; // Adjust path

part 'profile_view_model.g.dart';

@riverpod
class ProfileViewModel extends _$ProfileViewModel {
  @override
  AsyncValue<AuthenticatedUser?> build() {
  
    final sessionAsync = ref.watch(sessionProvider);

    return sessionAsync;
  }
}