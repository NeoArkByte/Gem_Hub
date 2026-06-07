// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gem_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gemList)
final gemListProvider = GemListProvider._();

final class GemListProvider extends $FunctionalProvider<AsyncValue<List<Gem>>,
        List<Gem>, FutureOr<List<Gem>>>
    with $FutureModifier<List<Gem>>, $FutureProvider<List<Gem>> {
  GemListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gemListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gemListHash();

  @$internal
  @override
  $FutureProviderElement<List<Gem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Gem>> create(Ref ref) {
    return gemList(ref);
  }
}

String _$gemListHash() => r'4df0c200093987a18d755b7ca1877f73fb3aeb6d';

@ProviderFor(approvedGems)
final approvedGemsProvider = ApprovedGemsProvider._();

final class ApprovedGemsProvider extends $FunctionalProvider<
        AsyncValue<List<Gem>>, List<Gem>, FutureOr<List<Gem>>>
    with $FutureModifier<List<Gem>>, $FutureProvider<List<Gem>> {
  ApprovedGemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'approvedGemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$approvedGemsHash();

  @$internal
  @override
  $FutureProviderElement<List<Gem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Gem>> create(Ref ref) {
    return approvedGems(ref);
  }
}

String _$approvedGemsHash() => r'b41ce103c4c5afdd426795475d2046cade008bd9';

@ProviderFor(latestApprovedGems)
final latestApprovedGemsProvider = LatestApprovedGemsProvider._();

final class LatestApprovedGemsProvider extends $FunctionalProvider<
        AsyncValue<List<Gem>>, List<Gem>, FutureOr<List<Gem>>>
    with $FutureModifier<List<Gem>>, $FutureProvider<List<Gem>> {
  LatestApprovedGemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'latestApprovedGemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$latestApprovedGemsHash();

  @$internal
  @override
  $FutureProviderElement<List<Gem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Gem>> create(Ref ref) {
    return latestApprovedGems(ref);
  }
}

String _$latestApprovedGemsHash() =>
    r'e3bcce3be6b52a65bfd082b71714a429467f378d';

@ProviderFor(pendingGems)
final pendingGemsProvider = PendingGemsProvider._();

final class PendingGemsProvider extends $FunctionalProvider<
        AsyncValue<List<Gem>>, List<Gem>, FutureOr<List<Gem>>>
    with $FutureModifier<List<Gem>>, $FutureProvider<List<Gem>> {
  PendingGemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'pendingGemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$pendingGemsHash();

  @$internal
  @override
  $FutureProviderElement<List<Gem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Gem>> create(Ref ref) {
    return pendingGems(ref);
  }
}

String _$pendingGemsHash() => r'ad60436e86aeab8f9bf6a70abb82360b5220eb5e';

@ProviderFor(userSpecificGems)
final userSpecificGemsProvider = UserSpecificGemsProvider._();

final class UserSpecificGemsProvider extends $FunctionalProvider<
        AsyncValue<List<Gem>>, List<Gem>, FutureOr<List<Gem>>>
    with $FutureModifier<List<Gem>>, $FutureProvider<List<Gem>> {
  UserSpecificGemsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSpecificGemsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSpecificGemsHash();

  @$internal
  @override
  $FutureProviderElement<List<Gem>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Gem>> create(Ref ref) {
    return userSpecificGems(ref);
  }
}

String _$userSpecificGemsHash() => r'0e5b21c6ef3359383e0b762b90e8701735355904';
