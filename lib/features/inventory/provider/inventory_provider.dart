import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';

part 'inventory_provider.g.dart';

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  // Define the helper here so you can use it in all methods
  final _dbHelper = DatabaseHelper();

  @override
  Future<List<GemstoneModel>> build() async {
    return _refreshList();
  }

  /// Internal helper to fetch the latest data from SQLite
  Future<List<GemstoneModel>> _refreshList() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'gemstones',
      orderBy: 'id DESC',
    );
    return maps.map((e) => GemstoneModel.fromMap(e)).toList();
  }

  /// Adds a new gemstone and refreshes the state
  Future<void> addGemstone(GemstoneModel gem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = await _dbHelper.database;
      await db.insert('gemstones', gem.toMap());
      return _refreshList();
    });
  }

  /// Deletes a gemstone and refreshes the state
  Future<void> deleteGemstone(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = await _dbHelper.database;
      await db.delete('gemstones', where: 'id = ?', whereArgs: [id]);
      return _refreshList();
    });
  }

  /// Updates an existing gemstone in the database and UI
  Future<void> updateGemstone(GemstoneModel updatedGem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final db = await _dbHelper.database;
      
      // 1. Update the record in SQLite
      await db.update(
        'gemstones',
        updatedGem.toMap(),
        where: 'id = ?',
        whereArgs: [updatedGem.id],
      );

      // 2. Return the fresh list to update the UI state
      return _refreshList();
    });
  }
}