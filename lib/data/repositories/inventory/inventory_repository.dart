// lib/data/repositories/inventory/inventory_repository.dart
import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';

class InventoryRepository {
  final DatabaseHelper _db;

  InventoryRepository([DatabaseHelper? db]) : _db = db ?? DatabaseHelper();

  Future<List<GemstoneModel>> fetchGemstones() => _db.getAllGemstones();

  Future<int> insertGemstone(GemstoneModel gem) => _db.insertGemstone(gem);

  Future<void> deleteGemstone(int id) => _db.deleteGemstone(id);

  Future<void> updateGemstone(GemstoneModel gem) => _db.updateGemstone(gem);

  Future<List<String>> getGemVarieties() => _db.getGemVarieties();
}
