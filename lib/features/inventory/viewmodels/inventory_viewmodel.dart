import 'package:flutter_riverpod/legacy.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository_provider.dart';
import 'package:gemhub/data/services/media_vault_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

part 'inventory_viewmodel.g.dart';

@riverpod
class InventoryViewModel extends _$InventoryViewModel {
  InventoryRepository get _repository => ref.watch(inventoryRepositoryProvider);

  @override
  Future<List<GemstoneModel>> build() async {
    return _repository.fetchGemstones();
  }

  Future<List<GemstoneModel>> _refreshList() async {
    return _repository.fetchGemstones();
  }

  Future<void> deleteGemstone(int id) async {
    final vaultService = ref.read(mediaVaultProvider);
    final currentList = state.value ?? [];
    final gemToDelete = currentList.firstWhere((gem) => gem.id == id);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Delete from vault
      if (gemToDelete.firstImagePath != null) {
        await vaultService.deleteFromVault(p.basename(gemToDelete.firstImagePath!));
      }
      if (gemToDelete.finalImagePath != null) {
        await vaultService.deleteFromVault(p.basename(gemToDelete.finalImagePath!));
      }
      if (gemToDelete.firstVideoPath != null) {
        await vaultService.deleteFromVault(p.basename(gemToDelete.firstVideoPath!));
      }
      if (gemToDelete.finalVideoPath != null) {
        await vaultService.deleteFromVault(p.basename(gemToDelete.finalVideoPath!));
      }

      await _repository.deleteGemstone(id);
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
