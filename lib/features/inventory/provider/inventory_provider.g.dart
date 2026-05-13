// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(InventoryNotifier)
final inventoryProvider = InventoryNotifierProvider._();

final class InventoryNotifierProvider
    extends $AsyncNotifierProvider<InventoryNotifier, List<GemstoneModel>> {
  InventoryNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryNotifierHash();

  @$internal
  @override
  InventoryNotifier create() => InventoryNotifier();
}

String _$inventoryNotifierHash() => r'acc86c467b66675c590cbd6066d98beeb8ae492a';

abstract class _$InventoryNotifier extends $AsyncNotifier<List<GemstoneModel>> {
  FutureOr<List<GemstoneModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GemstoneModel>>, List<GemstoneModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GemstoneModel>>, List<GemstoneModel>>,
              AsyncValue<List<GemstoneModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
