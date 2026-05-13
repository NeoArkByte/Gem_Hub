import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:job_market/features/gem_market/provider/gem_list_provider.dart';

part 'gem_marketplace_viewmodel.g.dart';

@riverpod
class GemMarketplaceViewModel extends _$GemMarketplaceViewModel {
  List<Gem> _allGems = [];
  String _searchQuery = '';

  @override
  Future<List<Gem>> build() async {
    // Watch the raw data source.
    // When rawGemListProvider gets data, this build method re-runs.
    final gemsAsync = ref.watch(approvedGemsProvider);

    return gemsAsync.maybeWhen(
      data: (gems) {
        _allGems = gems;
        return _applyFilters(_allGems);
      },
      orElse: () => [], // Returns empty while loading/error
    );
  }

  List<Gem> _applyFilters(List<Gem> gems) {
    if (_searchQuery.isEmpty) return gems;
    return gems.where((gem) {
      final query = _searchQuery.toLowerCase();
      return gem.name.toLowerCase().contains(query);
    }).toList();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    state = AsyncData(_applyFilters(_allGems));
  }

  // Manually trigger a refresh of the RAW data provider
  Future<void> fetchGems() async {
    state = const AsyncLoading();
    // This forces the 'rawGemListProvider' to fetch from Django again
    ref.invalidate(gemListProvider);
    await ref.read(gemListProvider.future);
  }

  // CREATE / UPDATE / DELETE
  // Use the same pattern: perform action, then invalidate the raw provider
  Future<bool> addGem(Gem gem) async {
    try {
      await ref.read(gemRepositoryProvider).createGem(gem);
      ref.invalidate(gemListProvider); // Forces a fresh fetch
      return true;
    } catch (_) {
      return false;
    }
  }

  // updateGem and deleteGem follow the same logic as addGem
  void updateType(dynamic type) {}
}
