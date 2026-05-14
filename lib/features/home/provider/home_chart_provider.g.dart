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

String _$chartTrendDataHash() => r'93a07cea8e5be21a2a19121f74e90a9300c6da76';
