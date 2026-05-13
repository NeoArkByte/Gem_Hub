import 'package:job_market/data/models/job_market/job_model.dart';
import 'package:job_market/data/repositories/job_market/job_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'marketplace_viewmodel.g.dart';
class MarketplaceState {
  final String query;
  final String category;
  MarketplaceState({required this.query, required this.category});
}

@riverpod
class MarketplaceViewModel extends _$MarketplaceViewModel {
  String _query = '';
  String _category = 'All Jobs';

  @override
  Future<List<Job>> build() async {
    return _fetch();
  }

  Future<List<Job>> _fetch() async {
    final repository = ref.read(jobRepositoryProvider);
    return await repository.getApprovedJobs(
      keyword: _query,
      category: _category,
    );
  }

  Future<void> updateSearchQuery(String query) async {
    _query = query;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }

  Future<void> updateCategory(String category) async {
    _category = category;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch());
  }
}