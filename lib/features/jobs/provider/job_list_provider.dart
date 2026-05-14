import 'package:job_market/data/repositories/job_market/job_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/data/models/job_market/job_model.dart';


part 'job_list_provider.g.dart';


@riverpod
Future<List<Job>> pendingJobs(Ref ref) async {
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getPendingJobs();
}

// 2. Approved Jobs Provider (Marketplace එක සඳහා)
@riverpod
Future<List<Job>> approvedJobs(Ref ref) async {
  // Repository එකෙන් approved ලිස්ට් එක ඉල්ලනවා
  final repo = ref.watch(jobRepositoryProvider);
  return repo.getApprovedJobs();
}


@riverpod
Future<List<Job>> latestApprovedJobs(Ref ref) async {
  final approvedList = await ref.watch(approvedJobsProvider.future);
  
  return approvedList.reversed.take(5).toList();
}