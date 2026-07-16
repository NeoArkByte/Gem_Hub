// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gem_add_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GemAddViewModel)
final gemAddViewModelProvider = GemAddViewModelProvider._();

final class GemAddViewModelProvider
    extends $NotifierProvider<GemAddViewModel, bool> {
  GemAddViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'gemAddViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$gemAddViewModelHash();

  @$internal
  @override
  GemAddViewModel create() => GemAddViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$gemAddViewModelHash() => r'3c873a9632a54fe2f4a7276780d6c7eeeffe40cd';

abstract class _$GemAddViewModel extends $Notifier<bool> {
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
