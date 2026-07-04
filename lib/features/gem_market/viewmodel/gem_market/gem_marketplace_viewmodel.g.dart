// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gem_marketplace_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GemMarketplaceViewModel)
final gemMarketplaceViewModelProvider = GemMarketplaceViewModelProvider._();

final class GemMarketplaceViewModelProvider
    extends $AsyncNotifierProvider<GemMarketplaceViewModel, List<Gem>> {
  GemMarketplaceViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gemMarketplaceViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gemMarketplaceViewModelHash();

  @$internal
  @override
  GemMarketplaceViewModel create() => GemMarketplaceViewModel();
}

String _$gemMarketplaceViewModelHash() =>
    r'35d87b274a62458c8ca5fd4178c1e92eef9df5cc';

abstract class _$GemMarketplaceViewModel extends $AsyncNotifier<List<Gem>> {
  FutureOr<List<Gem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Gem>>, List<Gem>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Gem>>, List<Gem>>,
        AsyncValue<List<Gem>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
