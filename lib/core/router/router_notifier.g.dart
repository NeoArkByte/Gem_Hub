// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(routerLogic)
final routerLogicProvider = RouterLogicProvider._();

final class RouterLogicProvider
    extends $FunctionalProvider<RouterNotifier, RouterNotifier, RouterNotifier>
    with $Provider<RouterNotifier> {
  RouterLogicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerLogicProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerLogicHash();

  @$internal
  @override
  $ProviderElement<RouterNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RouterNotifier create(Ref ref) {
    return routerLogic(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RouterNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RouterNotifier>(value),
    );
  }
}

String _$routerLogicHash() => r'611c90fda11e4c87d144a1c33fd1a4b4d10c1103';
