import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';

class FakeInventoryRepository extends InventoryRepository {
  int fetchCount = 0;

  @override
  Future<List<GemstoneModel>> fetchGemstones() async {
    fetchCount++;
    return [
      GemstoneModel(
        id: 1,
        variety: 'Ruby',
        recordDate: '2024-01-01',
        buyingDate: '2024-01-01',
      ),
    ];
  }
}

void main() {
  test(
      'inventory providers can be watched together without reloading on teardown',
      () async {
    final fakeRepository = FakeInventoryRepository();
    final container = ProviderContainer(
      overrides: [
        inventoryRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );

    final inventorySub =
        container.listen(inventoryViewModelProvider, (_, __) {});
    final filteredSub = container.listen(filteredInventoryProvider, (_, __) {});

    await expectLater(
      container.read(inventoryViewModelProvider.future),
      completion(isA<List<GemstoneModel>>()),
    );

    expect(container.read(filteredInventoryProvider), isNotEmpty);
    expect(fakeRepository.fetchCount, 1);

    inventorySub.close();
    filteredSub.close();

    await container.read(inventoryViewModelProvider.future);

    expect(fakeRepository.fetchCount, 1);

    container.dispose();
  });
}
