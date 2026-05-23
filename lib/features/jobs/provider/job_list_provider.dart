import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';

// Build runner එකෙන් generate වෙන ෆයිල් එක
part 'job_list_provider.g.dart';

// 1. Pending Jobs Provider (Admin සඳහා පමණයි)
@riverpod
Future<List<Job>> pendingJobs(Ref ref) async {
  // Repository එක අරගෙන කෙලින්ම backend එකෙන් pending ලිස්ට් එක ඉල්ලනවා
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

// 3. Latest Approved Jobs (Home screen එකේ අලුත්ම ජොබ් 5 පෙන්වන්න)
// (Gem_list_provider එකේ තිබ්බ සුපිරිම කෑල්ල මම මේකටත් දැම්මා!)
@riverpod
Future<List<Job>> latestApprovedJobs(Ref ref) async {
  // කලින් fetch කරපු approved jobs ලිස්ට් එක දිහා බලන් ඉන්නවා
  final approvedList = await ref.watch(approvedJobsProvider.future);
  
  // ඒකෙන් අන්තිමට ආපු 5 විතරක් අරන් දෙනවා
  return approvedList.reversed.take(5).toList();
}