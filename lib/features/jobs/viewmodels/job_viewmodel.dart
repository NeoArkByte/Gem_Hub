import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_model.dart';
import 'package:job_market/data/repositories/job_repository.dart';



final pendingJobsViewModelProvider = StateNotifierProvider<PendingJobsViewModel, AsyncValue<List<Job>>>((ref) {
  // Repository eka aran ViewModel ekata pass karanawa
  final repository = ref.watch(jobRepositoryProvider);
  return PendingJobsViewModel(repository);
});

class PendingJobsViewModel extends StateNotifier<AsyncValue<List<Job>>> {
  final JobRepository _repository;

  // Initial state eka 'loading' widihata thiyala auto load karanawa
  PendingJobsViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadPendingJobs();
  }

  // Pending jobs tika DB eken adina function eka
  Future<void> loadPendingJobs() async {
    try {
      state = const AsyncValue.loading(); // Spinner eka pennanna kiyanawa
      final jobs = await _repository.getPendingJobs();
      state = AsyncValue.data(jobs); // Data awa kiyala UI ekata list eka yawanawa
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Error ekak awoth pennanawa
    }
  }

  // Job eka Accept/Reject karana function eka
  Future<void> updateJobStatus(int id, String status) async {
    try {
      await _repository.updateJobStatus(id, status);
      // Status eka update karata passe ayeth list eka refresh karanawa!
      await loadPendingJobs();
    } catch (e) {
      print("Error updating job status: $e");
    }
  }
}