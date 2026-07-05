import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:gemhub/data/models/job_market/job_model.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/data/repositories/job_market/job_repository_provider.dart';
import 'package:gemhub/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';

part 'admin_screen_viewmodel.g.dart';

class AdminScreenState {
  final List<Job> jobs;
  final List<Gem> gems;

  AdminScreenState({required this.jobs, required this.gems});
}

@riverpod
class AdminScreenViewModel extends _$AdminScreenViewModel {
  @override
  Future<AdminScreenState> build() async {
    final jobsRepo = ref.read(jobRepositoryProvider);
    final gemsRepo = ref.read(gemRepositoryProvider);

    final jobs = await jobsRepo.getAllJobs();
    final gems = await gemsRepo.getAllGems();

    return AdminScreenState(jobs: jobs, gems: gems);
  }

  Future<bool> updateJobStatus(String jobId, String status) async {
    final repository = ref.read(jobRepositoryProvider);
    final success = await repository.updateJobStatus(jobId, status);

    if (success) {
      ref.invalidateSelf();
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

  Future<bool> updateGemStatus(Gem gem, GemStatus status) async {
    final repository = ref.read(gemRepositoryProvider);
    final updatedGem = Gem(
      gemId: gem.gemId,
      owner: gem.owner,
      name: gem.name,
      carat: gem.carat,
      price: gem.price,
      description: gem.description,
      imageUrl: gem.imageUrl,
      location: gem.location,
      sellerPhone: gem.sellerPhone,
      variety: gem.variety,
      color: gem.color,
      certificateUrl: gem.certificateUrl,
      status: status,
    );

    try {
      await repository.updateGem(updatedGem);

      // Invalidate dependencies
      ref.invalidate(approvedGemsProvider);
      ref.invalidate(userSpecificGemsProvider);
      ref.invalidate(gemListProvider);
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteGem(String gemId) async {
    final repository = ref.read(gemRepositoryProvider);
    try {
      await repository.deleteGem(gemId);

      // Invalidate dependencies
      ref.invalidate(approvedGemsProvider);
      ref.invalidate(userSpecificGemsProvider);
      ref.invalidate(gemListProvider);
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }
}
