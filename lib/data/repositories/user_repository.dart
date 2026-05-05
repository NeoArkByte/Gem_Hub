import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';
import 'package:job_market/data/models/auth/user_model.dart';

// 👇 User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(DatabaseHelper());
});

class UserRepository {
  final DatabaseHelper _dbHelper;

  UserRepository(this._dbHelper);

  /// Fetch full user profile details from the 'users' table
  Future<UserModel?> getUserProfile(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  /// Update profile details (Name, Username, etc.)
  Future<int> updateProfile(UserModel user) async {
    final db = await _dbHelper.database;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}