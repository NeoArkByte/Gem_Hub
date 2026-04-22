import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/data/repositories/auth_repository.dart';

final authViewModelProvider =
    AsyncNotifierProvider.autoDispose<AuthViewModel, bool?>(() {
      return AuthViewModel();
    });

class AuthViewModel extends AutoDisposeAsyncNotifier<bool?> {
  @override
  bool? build() {
    return null;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      state = const AsyncValue.loading(); 
      await Future.delayed(const Duration(milliseconds: 500));
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.login(username, password);

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_user_id', user['username']);
        await prefs.setString('logged_in_user_name', user['name']);

        state = const AsyncValue.data(true); // Success
        return user;
      } else {
        state = const AsyncValue.data(false); // Fail (Wrong credentials)
        return null;
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // System error
      return null;
    }
  }

  Future<bool> signUp(String name, String username, String password) async {
    try {
      state = const AsyncValue.loading();

      await Future.delayed(const Duration(milliseconds: 500));

      final repository = ref.read(authRepositoryProvider);
      final isSuccess = await repository.registerUser(name, username, password);

      state = AsyncValue.data(isSuccess);
      return isSuccess;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
