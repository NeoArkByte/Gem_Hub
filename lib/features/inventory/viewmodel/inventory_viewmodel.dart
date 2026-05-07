import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/core/enums/gem_status.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/data/repositories/gem_repository.dart';

final inventoryViewModelProvider =
    AsyncNotifierProvider.autoDispose<InventoryViewModel, List<Gem>>(() {
      return InventoryViewModel();
    });

class InventoryViewModel extends AutoDisposeAsyncNotifier<List<Gem>> {
  @override
  Future<List<Gem>> build() async {
    return await _loadInventory();
  }

  Future<List<Gem>> _loadInventory() async {
    final repository = ref.read(gemRepositoryProvider);
    return await repository.getActiveGems();
  }

  Future<void> refreshInventory() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadInventory());
  }

  Future<bool> deleteGem(int id) async {
    try {
      final repository = ref.read(gemRepositoryProvider);
      await repository.deleteGem(id);
      await refreshInventory();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> archiveGem(Gem gem) async {
    try {
      final repository = ref.read(gemRepositoryProvider);
      final updatedGem = Gem(
        id: gem.id,
        ownerId: gem.ownerId,
        name: gem.name,
        type: gem.type,
        carat: gem.carat,
        price: gem.price,
        description: gem.description,
        color: gem.color,
        clarity: gem.clarity,
        treatment: gem.treatment,
        shape: gem.shape,
        origin: gem.origin,
        location: gem.location,
        imageUrl: gem.imageUrl,
        sellerPhone: gem.sellerPhone,
        videoUrl: gem.videoUrl,
        status: GemStatus.inactive,
        createdAt: gem.createdAt,
      );
      await repository.updateGem(updatedGem);
      await refreshInventory();
      return true;
    } catch (_) {
      return false;
    }
  }
}
