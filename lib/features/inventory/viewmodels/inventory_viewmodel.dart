import 'package:flutter_riverpod/legacy.dart';
import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:job_market/data/repositories/inventory/inventory_repository.dart';
import 'package:job_market/data/repositories/inventory/inventory_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'inventory_viewmodel.g.dart';

@riverpod
class InventoryViewModel extends _$InventoryViewModel {
  late final InventoryRepository _repository;

  @override
  Future<List<GemstoneModel>> build() async {
    _repository = ref.read(inventoryRepositoryProvider);
    return _repository.fetchGemstones();
  }

  Future<List<GemstoneModel>> _refreshList() async {
    return _repository.fetchGemstones();
  }

  Future<void> addGemstone(GemstoneModel gem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.insertGemstone(gem);
      return _refreshList();
    });
  }

  Future<void> deleteGemstone(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteGemstone(id);
      return _refreshList();
    });
  }

  Future<void> updateGemstone(GemstoneModel updatedGem) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.updateGemstone(updatedGem);
      return _refreshList();
    });
  }
}

final inventorySearchQueryProvider = StateProvider<String>((ref) => '');
final inventoryCategoryFilterProvider = StateProvider<String>((ref) => 'All');

@riverpod
List<GemstoneModel> filteredInventory(Ref ref) {
  final inventoryAsync = ref.watch(inventoryViewModelProvider);
  final searchQuery = ref.watch(inventorySearchQueryProvider);
  final selectedCategory = ref.watch(inventoryCategoryFilterProvider);

  return inventoryAsync.when(
    data: (inventory) {
      return inventory.where((gem) {
        final matchesSearch =
            gem.variety.toLowerCase().contains(searchQuery.toLowerCase()) ||
            gem.color.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory =
            selectedCategory == 'All' || gem.variety == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
}
