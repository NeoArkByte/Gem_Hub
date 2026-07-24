import 'package:gemhub/data/models/analytics/analytics_data_model.dart';

class AnalyticsState {
  final bool isLoading;
  final BusinessSummary? summary;
  final List<MonthlyPerformance> monthlyData;
  final List<GemTypePerformance> gemData;
  final List<String> businessInsights;

  AnalyticsState({
    this.isLoading = true,
    this.summary,
    this.monthlyData = const [],
    this.gemData = const [],
    this.businessInsights = const [],
  });

  AnalyticsState copyWith({
    bool? isLoading,
    BusinessSummary? summary,
    List<MonthlyPerformance>? monthlyData,
    List<GemTypePerformance>? gemData,
    List<String>? businessInsights,
  }) {
    return AnalyticsState(
      isLoading: isLoading ?? this.isLoading,
      summary: summary ?? this.summary,
      monthlyData: monthlyData ?? this.monthlyData,
      gemData: gemData ?? this.gemData,
      businessInsights: businessInsights ?? this.businessInsights,
    );
  }
}
