// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(filteredGemstones)
final filteredGemstonesProvider = FilteredGemstonesFamily._();

final class FilteredGemstonesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GemstoneModel>>,
          List<GemstoneModel>,
          FutureOr<List<GemstoneModel>>
        >
    with
        $FutureModifier<List<GemstoneModel>>,
        $FutureProvider<List<GemstoneModel>> {
  FilteredGemstonesProvider._({
    required FilteredGemstonesFamily super.from,
    required GemFilter super.argument,
  }) : super(
         retry: null,
         name: r'filteredGemstonesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$filteredGemstonesHash();

  @override
  String toString() {
    return r'filteredGemstonesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<GemstoneModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GemstoneModel>> create(Ref ref) {
    final argument = this.argument as GemFilter;
    return filteredGemstones(ref, filter: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredGemstonesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredGemstonesHash() => r'2f86c9c50c7916635fd12f20207024c84c05d334';

final class FilteredGemstonesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GemstoneModel>>, GemFilter> {
  FilteredGemstonesFamily._()
    : super(
        retry: null,
        name: r'filteredGemstonesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FilteredGemstonesProvider call({required GemFilter filter}) =>
      FilteredGemstonesProvider._(argument: filter, from: this);

  @override
  String toString() => r'filteredGemstonesProvider';
}

@ProviderFor(gemstoneVarieties)
final gemstoneVarietiesProvider = GemstoneVarietiesProvider._();

final class GemstoneVarietiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  GemstoneVarietiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gemstoneVarietiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gemstoneVarietiesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return gemstoneVarieties(ref);
  }
}

String _$gemstoneVarietiesHash() => r'9c727c5b6c23f86798e2a482b0bc3f712a19be9d';
