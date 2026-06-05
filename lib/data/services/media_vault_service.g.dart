// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_vault_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaVault)
final mediaVaultProvider = MediaVaultProvider._();

final class MediaVaultProvider
    extends
        $FunctionalProvider<
          MediaVaultService,
          MediaVaultService,
          MediaVaultService
        >
    with $Provider<MediaVaultService> {
  MediaVaultProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaVaultProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaVaultHash();

  @$internal
  @override
  $ProviderElement<MediaVaultService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaVaultService create(Ref ref) {
    return mediaVault(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaVaultService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaVaultService>(value),
    );
  }
}

String _$mediaVaultHash() => r'de0ebc98ef759a886b0f72c4c631e6000b3da983';
