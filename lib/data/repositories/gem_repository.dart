import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/datasources/local/database_helper.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';

import 'package:job_market/core/enums/gem_type.dart';

final gemRepositoryProvider = Provider<GemRepository>((ref) {
  return GemRepository(DatabaseHelper());
});

class GemRepository {
  final DatabaseHelper _dbHelper;

  GemRepository(this._dbHelper);

  Future<List<Gem>> getActiveGems() async {
    final maps = await _dbHelper.getActiveGems();
    return maps.map((map) => Gem.fromMap(map)).toList();
  }

  Future<List<Gem>> searchAndFilterGems(String keyword, GemType type) async {
    final maps = await _dbHelper.searchAndFilterGems(keyword, type.displayName);
    return maps.map((map) => Gem.fromMap(map)).toList();
  }

  Future<int> postNewGem(Gem gem) async {
    return await _dbHelper.insertGem(gem.toMap());
  }
}

