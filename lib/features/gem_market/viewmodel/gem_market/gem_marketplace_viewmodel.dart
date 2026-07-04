import 'package:gemhub/core/enums/gem_type.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';

part 'gem_marketplace_viewmodel.g.dart';

@riverpod
class GemMarketplaceViewModel extends _$GemMarketplaceViewModel {
  List<Gem> _allGems = [];
  String _searchQuery = '';
  GemType _selectedCategory = GemType.allGems;

  @override
  Future<List<Gem>> build() async {
    final gemsAsync = ref.watch(approvedGemsProvider);

    return gemsAsync.maybeWhen(
      data: (gems) {
        _allGems = gems;
        return _applyFilters(_allGems);
      },
      orElse: () => [],
    );
  }

  List<Gem> _applyFilters(List<Gem> gems) {
    final query = _searchQuery.toLowerCase();
    return gems.where((gem) {
      final gemType = GemType.fromString(gem.variety ?? '');
      final matchesCategory = _selectedCategory == GemType.allGems ||
          _selectedCategory == gemType ||
          (_selectedCategory == GemType.other && gemType == GemType.other);

      final matchesSearch = query.isEmpty ||
          gem.name.toLowerCase().contains(query) ||
          (gem.variety?.toLowerCase().contains(query) ?? false) ||
          (gem.location?.toLowerCase().contains(query) ?? false);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim();
    state = AsyncData(_applyFilters(_allGems));
  }

  void updateSelectedCategory(GemType category) {
    _selectedCategory = category;
    state = AsyncData(_applyFilters(_allGems));
  }

  Future<void> fetchGems() async {
    state = const AsyncLoading();

    ref.invalidate(approvedGemsProvider);
    await ref.read(approvedGemsProvider.future);
  }
}
