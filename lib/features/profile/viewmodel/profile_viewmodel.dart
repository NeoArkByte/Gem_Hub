import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';
import 'package:job_market/data/models/auth/user_model.dart';
import 'package:job_market/data/repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, AsyncValue<UserModel?>>((ref) {
  return ProfileViewModel(ref.watch(userRepositoryProvider));
});

class ProfileViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  final UserRepository _repository;

  ProfileViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final userIdStr = prefs.getString('logged_in_user_id') ?? '';
      
      final userId = int.tryParse(userIdStr); // Safety check for the FormatException
      
      if (userId != null) {
        final user = await _repository.getUserProfile(userId);
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  Future<void> fetchCurrentProfile() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('logged_in_username');

      if (username != null) {
        final userData = await DatabaseHelper().getUserData(username);
        if (userData != null) {
          state = AsyncValue.data(UserModel.fromMap(userData));
        } else {
          state = const AsyncValue.data(null);
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}