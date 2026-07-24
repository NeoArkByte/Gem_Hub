//lib/features/inventory/viewmodels/add_new_gemstone_viewmodel.dart

import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/data/models/inventory/media_processing_state.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';
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
    List<String> rawFirstLookPhotos = const [],
    String? rawFirstLookVideo,
    List<String> rawFinalPhotos = const [],
    String? rawFinalVideo,
  }) async {
    final repository = ref.read(inventoryRepositoryProvider);
    final vaultService = MediaVaultService();

    state = MediaProcessingState(isLoading: true, progress: 0);

    try {
      List<String> vaultedFirstPhotos = [];
      List<String> vaultedFinalPhotos = [];
      String? vFirstVideoPath = gem.firstLookVideo;
      String? vFinalVideoPath = gem.finalVideo;

      final int totalSteps = rawFirstLookPhotos.length +
          rawFinalPhotos.length +
          (rawFirstLookVideo != null ? 1 : 0) +
          (rawFinalVideo != null ? 1 : 0) +
          1;

      int currentStep = 0;

      void updateOverallProgress(double stepProgress) {
        final totalProgress = (currentStep + stepProgress) / totalSteps;
        state = state.copyWith(progress: totalProgress);
      }

      for (String path in rawFirstLookPhotos) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: path,
          type: MediaType.image,
        );

        if (f != null) {
          vaultedFirstPhotos.add(f.path);
        }

        currentStep++;
        updateOverallProgress(0);
      }

      for (String path in rawFinalPhotos) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: path,
          type: MediaType.image,
        );

        if (f != null) {
          vaultedFinalPhotos.add(f.path);
        }

        currentStep++;
        updateOverallProgress(0);
      }

      if (rawFirstLookVideo != null) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: rawFirstLookVideo,
          type: MediaType.video,
          onVideoProgress: (p) => updateOverallProgress(p / 100),
        );

        if (f != null) vFirstVideoPath = f.path;

        currentStep++;
        updateOverallProgress(0);
      }

      if (rawFinalVideo != null) {
        final f = await vaultService.compressAndSaveToVault(
          rawSourcePath: rawFinalVideo,
          type: MediaType.video,
          onVideoProgress: (p) => updateOverallProgress(p / 100),
        );

        if (f != null) vFinalVideoPath = f.path;

        currentStep++;
        updateOverallProgress(0);
      }

      var gemstoneToSave = gem.copyWith(
        firstLookPhotos: vaultedFirstPhotos,
        finalPhotos: vaultedFinalPhotos,
        firstLookVideo: vFirstVideoPath,
        finalVideo: vFinalVideoPath,
      );

      if (gemstoneToSave.id == null) {
        final id = await repository.insertGemstone(gemstoneToSave);
        gemstoneToSave = gemstoneToSave.copyWith(id: id);
      } else {
        try {
          await repository.updateGemstone(gemstoneToSave);
        } catch (_) {
          // Record not found — fall back to insert
          final id = await repository.insertGemstone(gemstoneToSave);
          gemstoneToSave = gemstoneToSave.copyWith(id: id);
        }
      }

      currentStep++;
      updateOverallProgress(0);

      ref.invalidate(inventoryViewModelProvider);

      state = state.copyWith(
        isLoading: false,
        progress: 1.0,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}