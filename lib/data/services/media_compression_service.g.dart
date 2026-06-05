// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_compression_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaCompression)
final mediaCompressionProvider = MediaCompressionProvider._();

final class MediaCompressionProvider
    extends
        $FunctionalProvider<
          MediaCompressionService,
          MediaCompressionService,
          MediaCompressionService
        >
    with $Provider<MediaCompressionService> {
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

String _$mediaCompressionHash() => r'07640406e7602c4f57b1657c2fe45e8df371a17f';
