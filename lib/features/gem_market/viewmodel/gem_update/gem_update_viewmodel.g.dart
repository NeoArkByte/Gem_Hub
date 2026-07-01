// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gem_update_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GemUpdateViewModel)
final gemUpdateViewModelProvider = GemUpdateViewModelProvider._();

final class GemUpdateViewModelProvider
    extends $NotifierProvider<GemUpdateViewModel, bool> {
  GemUpdateViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gemUpdateViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gemUpdateViewModelHash();

  @$internal
  @override
  GemUpdateViewModel create() => GemUpdateViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$gemUpdateViewModelHash() =>
    r'6765621626bda132aef03c31508b95836865d06a';

abstract class _$GemUpdateViewModel extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
