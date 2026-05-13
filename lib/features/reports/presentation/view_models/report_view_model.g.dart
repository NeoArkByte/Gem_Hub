// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider to fetch and filter gemstones based on UI selection

@ProviderFor(filteredGemstones)
final filteredGemstonesProvider = FilteredGemstonesFamily._();

/// Provider to fetch and filter gemstones based on UI selection

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
  /// Provider to fetch and filter gemstones based on UI selection
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

String _$filteredGemstonesHash() => r'c259ec36db779fe451791b9fd76cb1dbdef2a936';

/// Provider to fetch and filter gemstones based on UI selection

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

  /// Provider to fetch and filter gemstones based on UI selection

  FilteredGemstonesProvider call({required GemFilter filter}) =>
      FilteredGemstonesProvider._(argument: filter, from: this);

  @override
  String toString() => r'filteredGemstonesProvider';
}

/// NEW: Provider to fetch unique varieties currently in the database

@ProviderFor(gemstoneVarieties)
final gemstoneVarietiesProvider = GemstoneVarietiesProvider._();

/// NEW: Provider to fetch unique varieties currently in the database

final class GemstoneVarietiesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// NEW: Provider to fetch unique varieties currently in the database
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

String _$gemstoneVarietiesHash() => r'ebb4cb7ce92caebb5bfdda2373edd1b58f72544f';
