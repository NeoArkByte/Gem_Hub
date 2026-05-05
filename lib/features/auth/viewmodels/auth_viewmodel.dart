import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';
import 'package:job_market/data/models/auth/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. The Provider: This injects DatabaseHelper into the ViewModel
final authViewModelProvider = StateNotifierProvider<AuthViewModel, AsyncValue<UserModel?>>((ref) {
  return AuthViewModel(DatabaseHelper());
});

class AuthViewModel extends StateNotifier<AsyncValue<UserModel?>> {
  final DatabaseHelper _dbHelper;

  AuthViewModel(this._dbHelper) : super(const AsyncValue.data(null));

  // --- LOGIN LOGIC ---
  Future<UserModel?> login(String username, String password) async {
  state = const AsyncValue.loading();
  try {
    final userMap = await _dbHelper.loginUser(username, password);

    if (userMap != null) {
      final user = UserModel.fromMap(userMap);

      // This is the critical part for the Profile View to work
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('logged_in_user_id', user.id.toString());
      await prefs.setString('logged_in_username', user.username);

      state = AsyncValue.data(user);
      return user;
    }
    state = const AsyncValue.data(null);
    return null;
  } catch (e, stack) {
    state = AsyncValue.error(e, stack);
    return null;
  }
}

  // --- SIGN UP LOGIC ---
  Future<UserModel?> signUp(String name, String username, String password) async {
    state = const AsyncValue.loading();
    try {
      // Prepare the map for database insertion
      final newUserMap = {
        'name': name,
        'username': username,
        'password': password,
        'title': 'GEMOLOGIST', // Default title
        'items_count': 0,
        'rating': 0.0,
        'sales_count': '0',
        'member_since': _getCurrentMonthYear(),
      };

      final id = await _dbHelper.registerUser(newUserMap);
      
      if (id > 0) {
        final user = UserModel.fromMap({...newUserMap, 'id': id});
        state = AsyncValue.data(user);
        return user;
      }
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  String _getCurrentMonthYear() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return "${months[now.month - 1]} ${now.year}";
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_in_user_id');
    await prefs.remove('logged_in_username');
    state = const AsyncValue.data(null);
  }
}