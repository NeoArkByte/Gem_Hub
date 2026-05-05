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
  Future<int?> registerUser(String name, String username, String password) async {
    final db = await _dbHelper.database;
    try {
      // db.insert returns the primary key (id) of the inserted row
      final int id = await db.insert('users', {
        'name': name,
        'username': username,
        'password': password,
        'title': 'SENIOR GEMOLOGIST', // Default title for your UI
        'items_count': 0,
        'rating': 0.0,
        'sales_count': '0',
        'member_since': 'May 2026'
      });
      return id; 
    } catch (e) {
      print("Registration error: $e");
      return null; 
    }
  }
}