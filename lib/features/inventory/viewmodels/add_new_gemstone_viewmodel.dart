import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:job_market/data/repositories/inventory/inventory_repository.dart';
import 'package:job_market/data/repositories/inventory/inventory_repository_provider.dart';
import 'package:job_market/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_new_gemstone_viewmodel.g.dart';

@riverpod
class AddNewGemstoneViewModel extends _$AddNewGemstoneViewModel {
  @override
  Future<void> build() async {}

  Future<void> saveGemstone(GemstoneModel gem) async {
    final repository = ref.read(inventoryRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (gem.id == null) {
        await repository.insertGemstone(gem);
      } else {
        await repository.updateGemstone(gem);
      }
      ref.invalidate(inventoryViewModelProvider);
    });
  }
}
