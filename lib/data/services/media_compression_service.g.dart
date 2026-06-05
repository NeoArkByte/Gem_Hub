// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_compression_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// --- RIVERPOD GENERATOR ---
/// Declares the auto-scoping provider tracking your service lifetime

@ProviderFor(mediaCompression)
final mediaCompressionProvider = MediaCompressionProvider._();

/// --- RIVERPOD GENERATOR ---
/// Declares the auto-scoping provider tracking your service lifetime

final class MediaCompressionProvider
    extends
        $FunctionalProvider<
          MediaCompressionService,
          MediaCompressionService,
          MediaCompressionService
        >
    with $Provider<MediaCompressionService> {
  /// --- RIVERPOD GENERATOR ---
  /// Declares the auto-scoping provider tracking your service lifetime
  MediaCompressionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaCompressionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaCompressionHash();

  @$internal
  @override
  $ProviderElement<MediaCompressionService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MediaCompressionService create(Ref ref) {
    return mediaCompression(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaCompressionService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaCompressionService>(value),
    );
  }
}

String _$mediaCompressionHash() => r'eb8656f9284b6ae040cedc9a70dd92ea09552280';
