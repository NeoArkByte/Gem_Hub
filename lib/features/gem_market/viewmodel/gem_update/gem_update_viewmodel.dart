import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/data/repositories/gem_market/gem_repository.dart';
import 'package:gemhub/data/services/storage_service.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';

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
    File? newImageFile, 
    File?
    newCertificateFile, 
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
      final storageService = StorageService();

      
      String? finalImageUrl = originalGem.imageUrl;
      String? finalCertUrl = originalGem.certificateUrl;

      if (newImageFile != null) {
        finalImageUrl = await storageService.updateFile(
          bucket: 'listings',
          newFile: newImageFile,
          userId: supabaseUid,
          oldUrlOrPath: originalGem.imageUrl,
        );
      }

      if (newCertificateFile != null) {
        finalCertUrl = await storageService.updateFile(
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
