import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';
import 'package:gemhub/features/gem_market/viewmodel/gem_market/gem_marketplace_viewmodel.dart';

void main() {
  test(
      'GemMarketplaceViewModel filters approved gems by carat weight, color, and price',
      () async {
    final testGems = [
      Gem(
        gemId: '1',
        owner: 'user1',
        name: 'Blue Sapphire',
        carat: 2.5,
        price: 150000,
        color: 'Blue',
        variety: 'Sapphire',
      ),
      Gem(
        gemId: '2',
        owner: 'user1',
        name: 'Red Ruby',
        carat: 1.2,
        price: 90000,
        color: 'Red',
        variety: 'Ruby',
      ),
      Gem(
        gemId: '3',
        owner: 'user2',
        name: 'Yellow Sapphire',
        carat: 5.0,
        price: 500000,
        color: 'Yellow',
        variety: 'Sapphire',
      ),
      Gem(
        gemId: '4',
        owner: 'user2',
        name: 'White Diamond',
        carat: 0.8,
        price: 300000,
        color: 'White',
        variety: 'Diamond',
      ),
      Gem(
        gemId: '5',
        owner: 'user3',
        name: 'Green Emerald',
        carat: 3.0,
        price: 200000,
        color: 'Green',
        variety: 'Emerald',
      ),
    ];

    final container = ProviderContainer(
      overrides: [
        approvedGemsProvider.overrideWith((ref) => Future.value(testGems)),
      ],
    );

    final subscription =
        container.listen(gemMarketplaceViewModelProvider, (_, __) {});

    // Initial load
    await expectLater(
      container.read(gemMarketplaceViewModelProvider.future),
      completion(hasLength(5)),
    );

    final viewModel = container.read(gemMarketplaceViewModelProvider.notifier);

    // Test 1: Filter by Weight (Carat) (min: 2.0, max: 4.0)
    // Emerald (3.0) and Blue Sapphire (2.5) should match.
    viewModel.updateFilters(minWeight: 2.0, maxWeight: 4.0);
    var filtered = container.read(gemMarketplaceViewModelProvider).value;
    expect(filtered, isNotNull);
    expect(filtered!.length, equals(2));
    expect(filtered.any((g) => g.name == 'Blue Sapphire'), isTrue);
    expect(filtered.any((g) => g.name == 'Green Emerald'), isTrue);

    // Test 2: Filter by Color (Blue)
    viewModel.updateFilters(selectedColor: 'Blue');
    filtered = container.read(gemMarketplaceViewModelProvider).value;
    expect(filtered!.length, equals(1));
    expect(filtered.first.name, equals('Blue Sapphire'));

    // Test 3: Filter by Price Range (min: 100000, max: 350000)
    // With color reset, should match Blue Sapphire (150K), White Diamond (300K), Green Emerald (200K)
    viewModel.updateFilters(minPrice: 100000, maxPrice: 350000);
    filtered = container.read(gemMarketplaceViewModelProvider).value;
    expect(filtered!.length, equals(3));
    expect(filtered.any((g) => g.name == 'Blue Sapphire'), isTrue);
    expect(filtered.any((g) => g.name == 'White Diamond'), isTrue);
    expect(filtered.any((g) => g.name == 'Green Emerald'), isTrue);

    // Test 4: Combine filters (Color: Green, Max Price: 250000, Min Carat: 2.0)
    // Green Emerald (3.0 carats, 200000 price, Green color) should match.
    viewModel.updateFilters(
      selectedColor: 'Green',
      maxPrice: 250000,
      minWeight: 2.0,
    );
    filtered = container.read(gemMarketplaceViewModelProvider).value;
    expect(filtered!.length, equals(1));
    expect(filtered.first.name, equals('Green Emerald'));

    // Test 5: Reset Filters
    viewModel.resetFilters();
    filtered = container.read(gemMarketplaceViewModelProvider).value;
    expect(filtered!.length, equals(5));

    subscription.close();
    container.dispose();
  });
}
