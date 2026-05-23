import 'package:gemhub/core/enums/gem_status.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:gemhub/features/auth/provider/session_provider.dart';
import 'package:gemhub/features/gem_market/provider/gem_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gem_update_viewmodel.g.dart';

@riverpod
class GemUpdateViewModel extends _$GemUpdateViewModel {
  @override
  bool build() {
    return false;
  }

  Future<bool> updateGem({
    required String gemId,
    required String name,
    double? carat,
    double? price,
    String? description,
    String? location,
    String? sellerPhone,
    String? variety,
    String? color,
    String? imageUrl,
    String? certificateUrl,
  }) async {
    final sessionAsync = ref.read(sessionProvider);
    final currentUser = sessionAsync.value;

    if (currentUser?.supabaseUser == null) {
      return false;
    }

    final owner =
        currentUser?.profile?.id ??
        currentUser?.profile?.profileId ??
        currentUser?.supabaseUser?.id ??
        'anonymous';

    final gem = Gem(
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
      imageUrl: imageUrl,
      certificateUrl: certificateUrl,
      status: GemStatus.PENDING, // Might want to keep original status or reset to pending
    );

    try {
      await ref.read(gemRepositoryProvider).updateGem(gem);
      ref.invalidate(gemListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}
