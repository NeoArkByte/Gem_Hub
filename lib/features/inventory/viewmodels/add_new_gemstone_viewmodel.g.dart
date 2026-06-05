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
    extends $NotifierProvider<AddNewGemstoneViewModel, MediaProcessingState> {
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaProcessingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaProcessingState>(value),
    );
  }
}

String _$addNewGemstoneViewModelHash() =>
    r'c50a6fa86619f27ae627b8373155d4a73dd6f284';

abstract class _$AddNewGemstoneViewModel
    extends $Notifier<MediaProcessingState> {
  MediaProcessingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MediaProcessingState, MediaProcessingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MediaProcessingState, MediaProcessingState>,
              MediaProcessingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
