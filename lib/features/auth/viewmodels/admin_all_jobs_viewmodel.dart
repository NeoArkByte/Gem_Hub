import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';

part 'admin_all_jobs_viewmodel.g.dart';

@riverpod
class AdminAllJobsViewModel extends _$AdminAllJobsViewModel {
  @override
  Future<List<Job>> build() async {
    final repository = ref.read(jobRepositoryProvider);
    return repository.getAllJobs();
  }

  Future<bool> updateJobStatus(String jobId, String status) async {
    final repository = ref.read(jobRepositoryProvider);
    final success = await repository.updateJobStatus(jobId, status);

    if (success) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async => await repository.getAllJobs());
    }
    return success;
  }

  Future<bool> deleteJob(String jobId) async {
    final repository = ref.read(jobRepositoryProvider);
    final success = await repository.deleteJob(jobId);

    if (success) {
      ref.invalidateSelf();
    }
    return success;
  }
}
