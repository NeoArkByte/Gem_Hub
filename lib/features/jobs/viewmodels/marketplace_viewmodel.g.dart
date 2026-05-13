// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MarketplaceViewModel)
final marketplaceViewModelProvider = MarketplaceViewModelProvider._();

final class MarketplaceViewModelProvider
    extends $AsyncNotifierProvider<MarketplaceViewModel, List<Job>> {
  MarketplaceViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'marketplaceViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$marketplaceViewModelHash();

  @$internal
  @override
  MarketplaceViewModel create() => MarketplaceViewModel();
}

String _$marketplaceViewModelHash() =>
    r'e4002af806d1fae0404b753d466af928f24fe9bf';

abstract class _$MarketplaceViewModel extends $AsyncNotifier<List<Job>> {
  FutureOr<List<Job>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Job>>, List<Job>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Job>>, List<Job>>,
              AsyncValue<List<Job>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
