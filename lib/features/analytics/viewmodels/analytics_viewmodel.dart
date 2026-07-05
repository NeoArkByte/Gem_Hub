// lib/features/analytics/viewmodels/analytics_viewmodel.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';
import 'package:gemhub/data/repositories/analytics/analytics_repository.dart';
import 'package:gemhub/data/services/analytics/analytics_service.dart';

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

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final repository = AnalyticsRepository();
  return AnalyticsService(repository);
});

final analyticsViewModelProvider =
    StateNotifierProvider<AnalyticsViewModel, AnalyticsState>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return AnalyticsViewModel(service);
});

class AnalyticsViewModel extends StateNotifier<AnalyticsState> {
  final AnalyticsService _service;

  AnalyticsViewModel(this._service) : super(AnalyticsState()) {
    // ignore: discarded_futures
    loadAnalytics();
  }

  Future<void> loadAnalytics({String? filterGemVariety}) async {
    state = state.copyWith(isLoading: true);

    try {
      final summary = await _service.fetchSummary(gemVariety: filterGemVariety);
      final monthly = await _service.fetchMonthlyPerformance();
      final gems = await _service.fetchTopGems();

      final insights = _generateInsights(summary, monthly, gems);

      state = state.copyWith(
        isLoading: false,
        summary: summary,
        monthlyData: monthly,
        gemData: gems,
        businessInsights: insights,
      );
    } catch (e) {
      // Handle error state appropriately
      state = state.copyWith(isLoading: false);
    }
  }

  List<String> _generateInsights(BusinessSummary summary,
      List<MonthlyPerformance> monthly, List<GemTypePerformance> gems) {
    List<String> insights = [];

    // Rule 1: Highest Profit Gem
    if (gems.isNotEmpty) {
      insights.add(
          "${gems.first.gemType} generates the highest average profit at LKR ${gems.first.averageProfit.toStringAsFixed(2)}.");
    }

    // Rule 2: Selling Time Analysis
    if (gems.length >= 2) {
      gems.sort((a, b) => a.averageSellingTime.compareTo(b.averageSellingTime));
      final fastest = gems.first;
      insights.add(
          "${fastest.gemType} sells the fastest, averaging ${fastest.averageSellingTime.toStringAsFixed(1)} days.");
    }

    // Rule 3: Profit Trend (Looking at last 2 months)
    if (monthly.length >= 2) {
      final lastMonth = monthly.last;
      final prevMonth = monthly[monthly.length - 2];

      if (lastMonth.profit > prevMonth.profit) {
        double increase =
            ((lastMonth.profit - prevMonth.profit) / prevMonth.profit) * 100;
        insights.add(
            "Profit has increased by ${increase.toStringAsFixed(1)}% compared to last month.");
      } else {
        insights.add(
            "Profit is currently trending downwards compared to the previous month.");
      }
    }

    return insights;
  }
}
