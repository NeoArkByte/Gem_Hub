import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:job_market/core/enums/gem_status.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:job_market/data/repositories/storage/storage_repository_provider.dart';
import 'package:job_market/features/auth/provider/session_provider.dart';
import 'package:job_market/features/gem_market/provider/gem_list_provider.dart';
import 'package:job_market/data/repositories/inventory/inventory_repository_provider.dart';

part 'gem_add_viewmodel.g.dart';

@riverpod
class GemAddViewModel extends _$GemAddViewModel {
  @override
  bool build() => false;

  Future<List<String>> getGemVarieties() async {
    return await ref.read(inventoryRepositoryProvider).getGemVarieties();
  }

  Future<bool> createGem({
    required String name,
    required File imageFile,
    File? certificateFile,
    double? carat,
    double? price,
    String? description,
    String? location,
    String? sellerPhone,
    String? variety,
    String? color,
  }) async {
    final storageRepo = ref.read(storageRepositoryProvider);
    final gemRepo = ref.read(gemRepositoryProvider);

    final session = ref.read(sessionProvider).value;
    final ownerProfileId = session?.profile?.id;
    final supabaseUid = session?.supabaseUser?.id;

    if (ownerProfileId == null || supabaseUid == null) return false;

    state = true;

    try {
      final imageUrl = await storageRepo.uploadListing(imageFile, supabaseUid);

      String? certUrl;
      if (certificateFile != null) {
        certUrl = await storageRepo.uploadDocument(
          certificateFile,
          supabaseUid,
        );
      }

      final gem = Gem(
        owner: ownerProfileId,
        name: name,
        carat: carat,
        price: price,
        description: description,
        location: location,
        sellerPhone: sellerPhone,
        variety: variety,
        color: color,
        imageUrl: imageUrl,
        certificateUrl: certUrl ?? '',
        status: GemStatus.APPROVED,
      );

      await gemRepo.createGem(gem);

      if (ref.mounted) {
        ref.invalidate(gemListProvider);
        state = false;
      }

      return true;
    } catch (e) {
      if (ref.mounted) {
        state = false;
      }
      return false;
    }
  }
}
