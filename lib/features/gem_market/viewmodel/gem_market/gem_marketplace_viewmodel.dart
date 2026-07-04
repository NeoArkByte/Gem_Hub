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

  double? _minWeight;
  double? _maxWeight;
  String? _selectedColor;
  double? _minPrice;
  double? _maxPrice;

  double? get minWeight => _minWeight;
  double? get maxWeight => _maxWeight;
  String? get selectedColor => _selectedColor;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;

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

      // Weight criteria filter (carat weight)
      bool matchesWeight = true;
      if (_minWeight != null &&
          (gem.carat == null || gem.carat! < _minWeight!)) {
        matchesWeight = false;
      }
      if (_maxWeight != null &&
          (gem.carat == null || gem.carat! > _maxWeight!)) {
        matchesWeight = false;
      }

      // Color filter (case-insensitive contains check)
      bool matchesColor = true;
      if (_selectedColor != null && _selectedColor!.isNotEmpty) {
        matchesColor =
            gem.color?.toLowerCase().contains(_selectedColor!.toLowerCase()) ??
                false;
      }

      // Price range filter
      bool matchesPrice = true;
      if (_minPrice != null && (gem.price == null || gem.price! < _minPrice!)) {
        matchesPrice = false;
      }
      if (_maxPrice != null && (gem.price == null || gem.price! > _maxPrice!)) {
        matchesPrice = false;
      }

      return matchesCategory &&
          matchesSearch &&
          matchesWeight &&
          matchesColor &&
          matchesPrice;
    }).toList();
  }

  void updateFilters({
    double? minWeight,
    double? maxWeight,
    String? selectedColor,
    double? minPrice,
    double? maxPrice,
  }) {
    _minWeight = minWeight;
    _maxWeight = maxWeight;
    _selectedColor = selectedColor;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    state = AsyncData(_applyFilters(_allGems));
  }

  void resetFilters() {
    _minWeight = null;
    _maxWeight = null;
    _selectedColor = null;
    _minPrice = null;
    _maxPrice = null;
    state = AsyncData(_applyFilters(_allGems));
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
