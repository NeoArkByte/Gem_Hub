// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gem_market_inventory_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GemMarketInventoryViewModel)
final gemMarketInventoryViewModelProvider =
    GemMarketInventoryViewModelProvider._();

final class GemMarketInventoryViewModelProvider
    extends $AsyncNotifierProvider<GemMarketInventoryViewModel, List<Gem>> {
  GemMarketInventoryViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemMarketInventoryViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemMarketInventoryViewModelHash();

  @$internal
  @override
  GemMarketInventoryViewModel create() => GemMarketInventoryViewModel();
}

String _$gemMarketInventoryViewModelHash() =>
    r'7c9fd78c405ed4d9c1c6b76a8badd1294e1514c2';

abstract class _$GemMarketInventoryViewModel extends $AsyncNotifier<List<Gem>> {
  FutureOr<List<Gem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Gem>>, List<Gem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Gem>>, List<Gem>>,
              AsyncValue<List<Gem>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
