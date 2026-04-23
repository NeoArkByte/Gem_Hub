import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/job_market/job_model.dart';
import 'package:job_market/data/repositories/job_repository.dart';

final postJobViewModelProvider =
    AsyncNotifierProvider.autoDispose<PostJobViewModel, bool>(() {
      return PostJobViewModel();
    });

class PostJobViewModel extends AutoDisposeAsyncNotifier<bool> {
  @override
  bool build() {
    return false;
  }

  Future<bool> publishJob(Job job) async {
    state = const AsyncValue.loading();

    final repository = ref.read(jobRepositoryProvider);

    state = await AsyncValue.guard(() async {
      await repository.insertJob(job);
      return true;
    });
    return !state.hasError;
  }
}
