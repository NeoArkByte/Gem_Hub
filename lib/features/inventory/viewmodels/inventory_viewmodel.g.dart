// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryViewModel)
final inventoryViewModelProvider = InventoryViewModelProvider._();

final class InventoryViewModelProvider
    extends $AsyncNotifierProvider<InventoryViewModel, List<GemstoneModel>> {
  InventoryViewModelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inventoryViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inventoryViewModelHash();

  @$internal
  @override
  InventoryViewModel create() => InventoryViewModel();
}

String _$inventoryViewModelHash() =>
    r'8479a494098155686ae551497548b20244c3538e';

abstract class _$InventoryViewModel
    extends $AsyncNotifier<List<GemstoneModel>> {
  FutureOr<List<GemstoneModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GemstoneModel>>, List<GemstoneModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<GemstoneModel>>, List<GemstoneModel>>,
        AsyncValue<List<GemstoneModel>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(filteredInventory)
final filteredInventoryProvider = FilteredInventoryProvider._();

final class FilteredInventoryProvider extends $FunctionalProvider<
    List<GemstoneModel>,
    List<GemstoneModel>,
    List<GemstoneModel>> with $Provider<List<GemstoneModel>> {
  FilteredInventoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredInventoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredInventoryHash();

  @$internal
  @override
  $ProviderElement<List<GemstoneModel>> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<GemstoneModel> create(Ref ref) {
    return filteredInventory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<GemstoneModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<GemstoneModel>>(value),
    );
  }
}

String _$filteredInventoryHash() => r'2189f7c36d23db4a9cbb21477742bf7ec75bcf8e';
