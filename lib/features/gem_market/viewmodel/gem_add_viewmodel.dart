import 'package:job_market/core/enums/gem_status.dart';
import 'package:job_market/data/models/gem_market/gem_model.dart';
import 'package:job_market/data/repositories/gem_market/gem_repository_provider.dart';
import 'package:job_market/features/auth/provider/session_provider.dart';
import 'package:job_market/features/gem_market/provider/gem_list_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'gem_add_viewmodel.g.dart';

@riverpod
class GemAddViewModel extends _$GemAddViewModel {
  @override
  bool build() {
    return false;
  }

  Future<bool> createGem({
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
      owner: owner,
      name: name,
      carat: carat,
      price: price,
      description: description,
      location: location,
      sellerPhone: sellerPhone,
      variety: variety,
      color: color,
      imageUrl: imageUrl ??
          'https://images.unsplash.com/photo-1599643477877-530eb83abc8e?w=700',
      certificateUrl: certificateUrl ?? 'https://example.com/dummy-certificate.pdf',
      status: GemStatus.PENDING,
    );

    try {
      await ref.read(gemRepositoryProvider).createGem(gem);
      ref.invalidate(gemListProvider);
      return true;
    } catch (e) {
      return false;
    }
  }
}
