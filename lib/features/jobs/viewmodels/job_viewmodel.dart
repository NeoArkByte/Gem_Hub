import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_market/job_model.dart';
import 'package:job_market/data/repositories/job_repository.dart';

final pendingJobsViewModelProvider = AsyncNotifierProvider.autoDispose<PendingJobsViewModel, List<Job>>(() {
  return PendingJobsViewModel();
});

class PendingJobsViewModel extends AutoDisposeAsyncNotifier<List<Job>> {
  
  @override
  Future<List<Job>> build() async {
    return _fetchPendingJobs();
  }

  Future<List<Job>> _fetchPendingJobs() async {
    final repository = ref.read(jobRepositoryProvider);
    return await repository.getPendingJobs();
  }

  Future<void> loadPendingJobs() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPendingJobs());
  }

  Future<void> updateJobStatus(int id, String status) async {
    try {
      final repository = ref.read(jobRepositoryProvider);
      await repository.updateJobStatus(id, status);
      await loadPendingJobs();
      
    } catch (e) {
      print("Error updating job status: $e");
    }
  }
}