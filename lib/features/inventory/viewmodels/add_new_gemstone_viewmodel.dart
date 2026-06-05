import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/media_processing_state.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository_provider.dart';
import 'package:gemhub/data/services/media_vault_service.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_new_gemstone_viewmodel.g.dart';

@riverpod
class AddNewGemstoneViewModel extends _$AddNewGemstoneViewModel {
  @override
  MediaProcessingState build() => MediaProcessingState();

  Future<void> saveGemstone({
    required GemstoneModel gem,
    String? rawFirstImagePath,
    String? rawFinalImagePath,
    String? rawFirstVideoPath,
    String? rawFinalVideoPath,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    final vaultService = ref.read(mediaVaultProvider);

    state = MediaProcessingState(isLoading: true, progress: 0);

    try {
      String? vFirstImagePath = gem.firstImagePath;
      String? vFinalImagePath = gem.finalImagePath;
      String? vFirstVideoPath = gem.firstVideoPath;
      String? vFinalVideoPath = gem.finalVideoPath;

      final int totalSteps = [
            rawFirstImagePath,
            rawFinalImagePath,
            rawFirstVideoPath,
            rawFinalVideoPath,
          ].where((e) => e != null).length +
          1; // +1 for database transactions

      int currentStep = 0;

      void updateOverallProgress(double stepProgress) {
        final totalProgress = (currentStep + stepProgress) / totalSteps;
        state = state.copyWith(progress: totalProgress);
      }

      // --- STEP 1: VAULT IMAGES ---
      if (rawFirstImagePath != null) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: rawFirstImagePath,
          type: MediaType.image,
        );
        vFirstImagePath = f?.path;
        currentStep++;
        updateOverallProgress(0);
      }

      if (rawFinalImagePath != null) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: rawFinalImagePath,
          type: MediaType.image,
        );
        vFinalImagePath = f?.path;
        currentStep++;
        updateOverallProgress(0);
      }

      // --- STEP 2: VAULT VIDEOS ---
      if (rawFirstVideoPath != null) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: rawFirstVideoPath,
          type: MediaType.video,
          onVideoProgress: (p) => updateOverallProgress(p / 100),
        );
        vFirstVideoPath = f?.path;
        currentStep++;
        updateOverallProgress(0);
      }

      if (rawFinalVideoPath != null) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: rawFinalVideoPath,
          type: MediaType.video,
          onVideoProgress: (p) => updateOverallProgress(p / 100),
        );
        vFinalVideoPath = f?.path;
        currentStep++;
        updateOverallProgress(0);
      }

      // --- STEP 3: RECONSTRUCT DATA ---
      final gemstoneToSave = gem.copyWith(
        firstImagePath: vFirstImagePath,
        finalImagePath: vFinalImagePath,
        firstVideoPath: vFirstVideoPath,
        finalVideoPath: vFinalVideoPath,
      );

      // --- STEP 4: DB STORAGE ---
      if (gemstoneToSave.id == null) {
        await repository.insertGemstone(gemstoneToSave);
      } else {
        await repository.updateGemstone(gemstoneToSave);
      }

      // Finalize progress metrics before clearing views
      currentStep++;
      updateOverallProgress(0);

      state = state.copyWith(isLoading: false, progress: 1.0, isSuccess: true);

      // --- STEP 5: MUTATION INVALIDATION ---
      // Invalidating inside a microtask blocks asynchronous rendering bugs
      Future.microtask(() {
        ref.invalidate(inventoryViewModelProvider);
      });

    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}