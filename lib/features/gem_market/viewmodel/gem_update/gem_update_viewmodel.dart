import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:gemhub/data/repositories/storage/storage_repository_provider.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository_provider.dart';

part 'gem_update_viewmodel.g.dart';

@riverpod
class GemUpdateViewModel extends _$GemUpdateViewModel {
  @override
  bool build() => false;

  Future<List<String>> getGemVarieties() async {
    return await ref.read(inventoryRepositoryProvider).getGemVarieties();
  }

  Future<bool> updateGem({
    required String gemId,
    required String name,
    required Gem originalGem,
    double? carat,
    double? price,
    String? description,
    String? location,
    String? sellerPhone,
    String? variety,
    String? color,
    File? newImageFile, // Explicitly pass the file if a new photo was picked
    File?
    newCertificateFile, // Explicitly pass the file if a new doc was picked
  }) async {
    final sessionAsync = ref.read(sessionProvider);
    final currentUser = sessionAsync.value;

    if (currentUser?.supabaseUser == null) return false;

    final supabaseUid = currentUser!.supabaseUser!.id;
    final owner =
        currentUser.profile?.id ??
        currentUser.profile?.profileId ??
        supabaseUid;

    state = true;
    final keepAliveLink = ref.keepAlive();

    try {
      final storageRepo = ref.read(storageRepositoryProvider);

      // Default both back to whatever the original gem already holds
      String? finalImageUrl = originalGem.imageUrl;
      String? finalCertUrl = originalGem.certificateUrl;

      // 1. Process new image upload if the file object is present
      if (newImageFile != null) {
        finalImageUrl = await storageRepo.updateFile(
          bucket: 'listings',
          newFile: newImageFile,
          userId: supabaseUid,
          oldUrlOrPath: originalGem.imageUrl,
        );
      }

      // 2. Process new certificate upload if the file object is present
      if (newCertificateFile != null) {
        finalCertUrl = await storageRepo.updateFile(
          bucket: 'documents',
          newFile: newCertificateFile,
          userId: supabaseUid,
          oldUrlOrPath: originalGem.certificateUrl,
        );
      }

      final updatedGem = Gem(
        gemId: gemId,
        owner: owner,
        name: name,
        carat: carat,
        price: price,
        description: description,
        location: location,
        sellerPhone: sellerPhone,
        variety: variety,
        color: color,
        imageUrl: finalImageUrl,
        // Fall back safely to original certificate data instead of an empty string
        certificateUrl: finalCertUrl ?? originalGem.certificateUrl ?? '',
        status: GemStatus.PENDING,
      );

      await ref.read(gemRepositoryProvider).updateGem(updatedGem);

      state = false;
      keepAliveLink.close();
      return true;
    } catch (e) {
      state = false;
      keepAliveLink.close();
      return false;
    }
  }
}
