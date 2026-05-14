import 'package:job_market/data/datasources/local/database_helper.dart';
import 'package:job_market/data/models/inventory/gemstone_model.dart';

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
    return db.insert('gemstones', gem.toMap());
  }

  Future<int> deleteGemstone(int id) async {
    final db = await _databaseHelper.database;
    return db.delete('gemstones', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateGemstone(GemstoneModel gem) async {
    final db = await _databaseHelper.database;
    return db.update(
      'gemstones',
      gem.toMap(),
      where: 'id = ?',
      whereArgs: [gem.id],
    );
  }
}
