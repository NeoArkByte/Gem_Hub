// lib/data/services/analytics/analytics_service.dart
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';
import 'package:gemhub/data/repositories/analytics/analytics_repository.dart';

class AnalyticsService {
  final AnalyticsRepository _repository;

  AnalyticsService(this._repository);

  Future<BusinessSummary> fetchSummary({String? gemVariety}) =>
      _repository.getBusinessSummary(gemVariety: gemVariety);

  Future<List<MonthlyPerformance>> fetchMonthlyPerformance() =>
      _repository.getMonthlyPerformance();

  Future<List<GemTypePerformance>> fetchTopGems() =>
      _repository.getTopPerformingGems();
}
