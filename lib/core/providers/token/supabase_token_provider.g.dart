// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_token_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Listens to auth state changes and provides the current access token.

@ProviderFor(accessTokenStream)
final accessTokenStreamProvider = AccessTokenStreamProvider._();

/// Listens to auth state changes and provides the current access token.

final class AccessTokenStreamProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, Stream<String?>>
    with $FutureModifier<String?>, $StreamProvider<String?> {
  /// Listens to auth state changes and provides the current access token.
  AccessTokenStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accessTokenStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accessTokenStreamHash();

  @$internal
  @override
  $StreamProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<String?> create(Ref ref) {
    return accessTokenStream(ref);
  }
}

String _$accessTokenStreamHash() => r'5164ce7da8069d0e01d1019e4135e817ced93387';

/// Provides the current access token as a simple string.
/// This is what we will read inside the Dio Interceptor.

@ProviderFor(currentAccessToken)
final currentAccessTokenProvider = CurrentAccessTokenProvider._();

/// Provides the current access token as a simple string.
/// This is what we will read inside the Dio Interceptor.

final class CurrentAccessTokenProvider
    extends $FunctionalProvider<String?, String?, String?>
    with $Provider<String?> {
  /// Provides the current access token as a simple string.
  /// This is what we will read inside the Dio Interceptor.
  CurrentAccessTokenProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAccessTokenProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAccessTokenHash();

  @$internal
  @override
  $ProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String? create(Ref ref) {
    return currentAccessToken(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$currentAccessTokenHash() =>
    r'541a9ebcd3b6f17ee658e598c124ec90790b1174';
