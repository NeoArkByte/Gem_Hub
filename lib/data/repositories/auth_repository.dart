import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';

// 👇 Provider eka
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(DatabaseHelper());
});

class AuthRepository {
  final DatabaseHelper _dbHelper;

  AuthRepository(this._dbHelper);

  // Login karanawa
  Future<Map<String, dynamic>?> login(String username, String password) async {
    return await _dbHelper.loginUser(username, password);
  }

  // Aluth User kenek register karanawa
  Future<bool> registerUser(String name, String username, String password) async {
    final db = await _dbHelper.database;
    try {
      await db.insert('users', {
        'name': name,
        'username': username,
        'password': password
      });
      return true;
    } catch (e) {
      // Username eka kalinma thiyenawa nam error eka enawa (UNIQUE constraint)
      return false; 
    }
  }
}