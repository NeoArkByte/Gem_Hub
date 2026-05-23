// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_new_gemstone_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddNewGemstoneViewModel)
final addNewGemstoneViewModelProvider = AddNewGemstoneViewModelProvider._();

final class AddNewGemstoneViewModelProvider
    extends $AsyncNotifierProvider<AddNewGemstoneViewModel, void> {
  AddNewGemstoneViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addNewGemstoneViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addNewGemstoneViewModelHash();

  @$internal
  @override
  AddNewGemstoneViewModel create() => AddNewGemstoneViewModel();
}

String _$addNewGemstoneViewModelHash() =>
    r'77bc96a491ab93e34aa62992480992c3ec7740d1';

abstract class _$AddNewGemstoneViewModel extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
