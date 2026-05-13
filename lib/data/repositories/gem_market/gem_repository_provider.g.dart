// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gem_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(gemRepository)
final gemRepositoryProvider = GemRepositoryProvider._();

final class GemRepositoryProvider
    extends $FunctionalProvider<GemRepository, GemRepository, GemRepository>
    with $Provider<GemRepository> {
  GemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemRepositoryHash();

  @$internal
  @override
  $ProviderElement<GemRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GemRepository create(Ref ref) {
    return gemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GemRepository>(value),
    );
  }
}

String _$gemRepositoryHash() => r'8f644a3247cc4d678489fb80650f04075852ba1e';
