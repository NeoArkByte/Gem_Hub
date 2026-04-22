import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_model.dart';
import 'package:job_market/data/repositories/job_repository.dart';

final marketplaceViewModelProvider =
    AsyncNotifierProvider.autoDispose<MarketplaceViewModel, List<Job>>(() {
      return MarketplaceViewModel();
    });

class MarketplaceViewModel extends AutoDisposeAsyncNotifier<List<Job>> {
  String _currentQuery = '';
  String _currentCategory = 'All Jobs';

  @override
  Future<List<Job>> build() async {
    return _fetchJobsFromRepo();
  }

  Future<List<Job>> _fetchJobsFromRepo() async {
    final repository = ref.read(jobRepositoryProvider);
    return await repository.searchAndFilterJobs(
      _currentQuery,
      _currentCategory,
    );
  }

  Future<void> updateSearchQuery(String query) async {
    _currentQuery = query;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchJobsFromRepo());
  }

  Future<void> updateCategory(String category) async {
    _currentCategory = category;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchJobsFromRepo());
  }

  Future<void> fetchJobs() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchJobsFromRepo());
  }
}
