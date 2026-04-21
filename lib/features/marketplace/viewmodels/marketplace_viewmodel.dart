import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_model.dart';
import 'package:job_market/data/repositories/job_repository.dart';

final marketplaceViewModelProvider = StateNotifierProvider.autoDispose<MarketplaceViewModel, AsyncValue<List<Job>>>((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return MarketplaceViewModel(repository);
});

class MarketplaceViewModel extends StateNotifier<AsyncValue<List<Job>>> {
  final JobRepository _repository;

  String _currentQuery = '';
  String _currentCategory = 'All Jobs';

  MarketplaceViewModel(this._repository) : super(const AsyncValue.loading()) {
    fetchJobs(); 
  }

  Future<void> fetchJobs() async {
    try {
      state = const AsyncValue.loading();
      final jobs = await _repository.searchAndFilterJobs(_currentQuery, _currentCategory);
      state = AsyncValue.data(jobs);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void updateSearchQuery(String query) {
    _currentQuery = query;
    fetchJobs(); 
  }

  void updateCategory(String category) {
    _currentCategory = category;
    fetchJobs();
  }
}