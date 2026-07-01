import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';

part 'my_jobs_viewmodel.g.dart';

@riverpod
class MyJobsViewModel extends _$MyJobsViewModel {
  @override
  Future<List<Job>> build() async {
    final authData = ref.read(sessionProvider).value;
    if (authData == null || authData.profile == null) return [];
    
    final repository = ref.read(jobRepositoryProvider);
    return repository.getMyJobs(authData.profile!.id);
  }

  Future<bool> deleteJob(String jobId) async {
    final repository = ref.read(jobRepositoryProvider);
    final isSuccess = await repository.deleteJob(jobId);
    
    if (isSuccess) {
      ref.invalidateSelf(); 
    }
    
    return isSuccess;
  }
}