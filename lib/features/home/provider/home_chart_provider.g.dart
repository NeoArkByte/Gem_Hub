// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_chart_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(chartTrendData)
final chartTrendDataProvider = ChartTrendDataProvider._();

final class ChartTrendDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChartTrendData>,
          ChartTrendData,
          FutureOr<ChartTrendData>
        >
    with $FutureModifier<ChartTrendData>, $FutureProvider<ChartTrendData> {
  ChartTrendDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chartTrendDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chartTrendDataHash();

  @$internal
  @override
  $FutureProviderElement<ChartTrendData> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChartTrendData> create(Ref ref) {
    return chartTrendData(ref);
  }
}

String _$chartTrendDataHash() => r'18c956cef4d6803f1e09122aabf0e2f0dd414686';

@ProviderFor(heatmapData)
final heatmapDataProvider = HeatmapDataProvider._();

final class HeatmapDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HeatmapCellData>>,
          List<HeatmapCellData>,
          FutureOr<List<HeatmapCellData>>
        >
    with
        $FutureModifier<List<HeatmapCellData>>,
        $FutureProvider<List<HeatmapCellData>> {
  HeatmapDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'heatmapDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$heatmapDataHash();

  @$internal
  @override
  $FutureProviderElement<List<HeatmapCellData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HeatmapCellData>> create(Ref ref) {
    return heatmapData(ref);
  }
}

String _$heatmapDataHash() => r'1a181db575b5951e10db2e70d4d35dcbcdd59ed6';
