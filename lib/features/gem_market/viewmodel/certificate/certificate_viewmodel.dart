import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:job_market/data/repositories/storage/storage_repository_provider.dart';

part 'certificate_viewmodel.g.dart';

@riverpod
class CertificateViewModel extends _$CertificateViewModel {
  @override
  FutureOr<String> build(String path) async {
    final storageRepo = ref.read(storageRepositoryProvider);
    return await storageRepo.getTemporaryUrl(path);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    ref.invalidateSelf();
    await future;
  }
}
