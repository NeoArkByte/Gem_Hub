import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/repositories/job_market/job_repository.dart';
import 'package:gemhub/features/jobs/viewmodels/marketplace_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';

part 'post_job_viewmodel.g.dart';

@riverpod
class PostJobViewModel extends _$PostJobViewModel {
  @override
  FutureOr<void> build() {}

  Future<bool> publishJob(Job job) async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(jobRepositoryProvider);
      final success = await repository.insertJob(job);

      if (success) {
        ref.invalidate(marketplaceViewModelProvider);
        state = const AsyncData(null);
        return true;
      } else {
        state = AsyncError('Failed to publish', StackTrace.current);
        return false;
      }
    } catch (e) {
      state = AsyncError(e.toString(), StackTrace.current);
      return false;
    }
  }
}
