// lib/data/repositories/analytics/analytics_repository.dart
import 'package:gemhub/data/datasources/local/database_helper.dart';
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';

class AnalyticsRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<BusinessSummary> getBusinessSummary({String? gemVariety}) =>
      _db.getBusinessSummary(gemVariety: gemVariety);

  Future<List<MonthlyPerformance>> getMonthlyPerformance() =>
      _db.getMonthlyPerformance();

  Future<List<GemTypePerformance>> getTopPerformingGems() =>
      _db.getTopPerformingGems();
}
