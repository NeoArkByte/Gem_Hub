import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';

class InventoryRepository {
  final DatabaseHelper _databaseHelper;

  InventoryRepository([DatabaseHelper? databaseHelper])
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<List<GemstoneModel>> fetchGemstones() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('gemstones', orderBy: 'id DESC');
    return maps.map((e) => GemstoneModel.fromMap(e)).toList();
  }

  Future<int> insertGemstone(GemstoneModel gem) async {
  final db = await _databaseHelper.database;

  final id = await db.insert('gemstones', gem.toMap());

  return id;
}

  Future<int> deleteGemstone(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('gemstones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateGemstone(GemstoneModel gem) async {
  final db = await _databaseHelper.database;

  final result = await db.update(
    'gemstones',
    gem.toMap(),
    where: 'id = ?',
    whereArgs: [gem.id],
  );

  if (result == 0) {
    throw Exception('Update failed: record not found for id ${gem.id}');
  }

  return result;
}

  Future<List<String>> getGemVarieties() async {
    return await _databaseHelper.getGemVarieties();
  }
}
