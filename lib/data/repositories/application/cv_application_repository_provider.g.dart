// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_application_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cvApplicationRepository)
final cvApplicationRepositoryProvider = CvApplicationRepositoryProvider._();

final class CvApplicationRepositoryProvider extends $FunctionalProvider<
    CvApplicationRepository,
    CvApplicationRepository,
    CvApplicationRepository> with $Provider<CvApplicationRepository> {
  CvApplicationRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cvApplicationRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cvApplicationRepositoryHash();

  @$internal
  @override
  $ProviderElement<CvApplicationRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CvApplicationRepository create(Ref ref) {
    return cvApplicationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CvApplicationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CvApplicationRepository>(value),
    );
  }
}

String _$cvApplicationRepositoryHash() =>
    r'f2e44730b9f1ca41d897e96b1ef6ccca2e0a1c39';
