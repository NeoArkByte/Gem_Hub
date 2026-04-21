import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_model.dart';
import 'package:job_market/data/repositories/job_repository.dart';

final postJobViewModelProvider = StateNotifierProvider.autoDispose<PostJobViewModel, AsyncValue<bool>>((ref) {
  final repository = ref.watch(jobRepositoryProvider);
  return PostJobViewModel(repository);
});

class PostJobViewModel extends StateNotifier<AsyncValue<bool>> {
  final JobRepository _repository;

  PostJobViewModel(this._repository) : super(const AsyncData(false));

  // Job eka DB ekata save karana logic eka
  Future<bool> publishJob(Job job) async {
    try {
      state = const AsyncLoading(); 
      await _repository.insertJob(job);
      state = const AsyncData(true); 
      return true;
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace); 
      return false;
    }
  }
}