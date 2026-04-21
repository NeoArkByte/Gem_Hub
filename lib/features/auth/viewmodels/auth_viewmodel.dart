import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_market/data/repositories/auth_repository.dart';

final authViewModelProvider = StateNotifierProvider.autoDispose<AuthViewModel, AsyncValue<bool?>>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthViewModel(repository);
});

class AuthViewModel extends StateNotifier<AsyncValue<bool?>> {
  final AuthRepository _repository;

  // Initial state eka Data(null) widihata thiyenne
  AuthViewModel(this._repository) : super(const AsyncData(null));

  Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      state = const AsyncLoading(); // Loading spinner eka
      
      // Delay ekak denawa loading eka pennanna (Passe API daddi meka ain karanna)
      await Future.delayed(const Duration(milliseconds: 500)); 
      
      final user = await _repository.login(username, password);
      
      if (user != null) {
        // User hitiyoth Session eka (ID eka) save karanawa
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_in_user_id', user['username']);
        await prefs.setString('logged_in_user_name', user['name']);
        
        state = const AsyncData(true); // Success
        return user;
      } else {
        state = const AsyncData(false); // Fail (Wrong credentials)
        return null;
      }
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace); // System error
      return null;
    }
  }

  Future<bool> signUp(String name, String username, String password) async {
    try {
      state = const AsyncLoading();
      
      await Future.delayed(const Duration(milliseconds: 500)); 
      
      final isSuccess = await _repository.registerUser(name, username, password);
      state = AsyncData(isSuccess);
      return isSuccess;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
      return false;
    }
  }
}