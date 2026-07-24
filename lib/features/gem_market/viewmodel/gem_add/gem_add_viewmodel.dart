import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/data/repositories/gem_market/gem_repository.dart';
import 'package:gemhub/data/services/storage_service.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/data/repositories/inventory/inventory_repository.dart';

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
    final session = ref.read(sessionProvider).value;
    final ownerProfileId = session?.profile?.id;
    final supabaseUid = session?.supabaseUser?.id;

    if (ownerProfileId == null || supabaseUid == null) return false;

    state = true;
    final keepAliveLink = ref.keepAlive();

    try {
      final storageService = StorageService();
      final gemRepo = ref.read(gemRepositoryProvider);

      // Upload files
      final imageUrl = await storageService.uploadListing(imageFile, supabaseUid);

      String? certUrl;
      if (certificateFile != null) {
        certUrl = await storageService.uploadDocument(
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
        status: GemStatus.PENDING,
      );

      // Create record
      await gemRepo.createGem(gem);

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
