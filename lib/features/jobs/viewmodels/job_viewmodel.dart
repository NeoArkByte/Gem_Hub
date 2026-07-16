import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/features/jobs/viewmodels/marketplace_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/repositories/job_market/job_repository.dart';

part 'job_viewmodel.g.dart';

@riverpod
class PendingJobsViewModel extends _$PendingJobsViewModel {
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

  Future<bool> updateJobStatus(dynamic id, String status) async {
    final jobId = id?.toString() ?? '';
    if (jobId.isEmpty) {
      print('ERROR: Missing job id for update');
      return false;
    }

    try {
      final repository = ref.read(jobRepositoryProvider);
      final success = await repository.updateJobStatus(jobId, status);

      if (success) {
        print("SUCCESS: Backend updated!");
        await loadPendingJobs();
        ref.invalidate(marketplaceViewModelProvider);
        return true;
      } else {
        print("ERROR: Backend update failed!");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }
}
