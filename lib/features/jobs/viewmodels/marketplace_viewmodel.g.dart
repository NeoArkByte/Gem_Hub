part of 'marketplace_viewmodel.dart';
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
    r'f625ba43f16d248634a0d218d41102e7fced136e';

abstract class _$MarketplaceViewModel extends $AsyncNotifier<List<Job>> {
  FutureOr<List<Job>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Job>>, List<Job>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Job>>, List<Job>>,
        AsyncValue<List<Job>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
