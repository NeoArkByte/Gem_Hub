// lib/features/inventory/provider/inventory_provider.dart
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/datasources/local/database_helper.dart';

part 'inventory_provider.g.dart';

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  final _db = DatabaseHelper();

  @override
  Future<List<GemstoneModel>> build() async {
    return _db.getAllGemstones();
  }

  /// Adds a new gemstone and refreshes the state.
  Future<void> addGemstone(GemstoneModel gem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.insertGemstone(gem);
      return _db.getAllGemstones();
    });
  }

  /// Deletes a gemstone and refreshes the state.
  Future<void> deleteGemstone(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.deleteGemstone(id);
      return _db.getAllGemstones();
    });
  }

  /// Updates an existing gemstone and refreshes the state.
  Future<void> updateGemstone(GemstoneModel updatedGem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _db.updateGemstone(updatedGem);
      return _db.getAllGemstones();
    });
  }
}