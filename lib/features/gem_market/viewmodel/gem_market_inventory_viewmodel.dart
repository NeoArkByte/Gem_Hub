import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/core/enums/gem_type.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';

part 'gem_market_inventory_viewmodel.g.dart';

@riverpod
class GemMarketInventoryViewModel extends _$GemMarketInventoryViewModel {
  List<Gem> _allGems = [];
  String _searchQuery = '';
  GemType _selectedCategory = GemType.allGems;

  @override
  Future<List<Gem>> build() async {
    final gems = await ref.watch(gemListProvider.future);
    _allGems = gems;
    return _applyFilters(gems);
  }

  Future<void> updateSearchQuery(String query) async {
    _searchQuery = query.trim();
    if (!ref.mounted) return;
    state = AsyncData(_applyFilters(_allGems));
  }

  Future<void> updateSelectedCategory(GemType category) async {
    _selectedCategory = category;
    if (!ref.mounted) return;
    state = AsyncData(_applyFilters(_allGems));
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
}
