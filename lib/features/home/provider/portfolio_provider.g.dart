// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'portfolio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(portfolioData)
final portfolioDataProvider = PortfolioDataProvider._();

final class PortfolioDataProvider extends $FunctionalProvider<
        AsyncValue<Map<String, double>>,
        Map<String, double>,
        FutureOr<Map<String, double>>>
    with
        $FutureModifier<Map<String, double>>,
        $FutureProvider<Map<String, double>> {
  PortfolioDataProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'portfolioDataProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$portfolioDataHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, double>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, double>> create(Ref ref) {
    return portfolioData(ref);
  }
}

String _$portfolioDataHash() => r'b600c662b7477ad47b4e5aea11cf6a80c71da8cc';
