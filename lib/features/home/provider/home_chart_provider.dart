import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:job_market/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_chart_provider.g.dart';

enum ChartRange { thisMonth, last6Months, lastYear }

extension ChartRangeLabel on ChartRange {
  String get displayName {
    switch (this) {
      case ChartRange.thisMonth:
        return 'This Month';
      case ChartRange.last6Months:
        return 'Last 6 Months';
      case ChartRange.lastYear:
        return 'Last Year';
    }
  }
}

final chartRangeProvider = StateProvider<ChartRange>(
  (ref) => ChartRange.last6Months,
);

class ChartTrendData {
  final List<double> values;
  final List<String> labels;
  final ChartRange range;
  final bool hasEnoughData;

  ChartTrendData({
    required this.values,
    required this.labels,
    required this.range,
    required this.hasEnoughData,
  });
}

@riverpod
Future<ChartTrendData> chartTrendData(Ref ref) async {
  final gems = await ref.watch(inventoryViewModelProvider.future);
  final range = ref.watch(chartRangeProvider);

  final now = DateTime.now();
  final List<String> labels = [];
  final List<double> values = [];

  if (range == ChartRange.thisMonth) {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    const weeks = 4;
    final weekLength = (lastDayOfMonth.day / weeks).ceil();

    for (var i = 0; i < weeks; i++) {
      final segmentStart = firstDayOfMonth.add(Duration(days: i * weekLength));
      final segmentEnd = DateTime(
        now.year,
        now.month,
        min(lastDayOfMonth.day, (i + 1) * weekLength),
      );
      labels.add('W${i + 1}');
      values.add(_sumForRange(gems, segmentStart, segmentEnd));
    }
  } else {
    final monthCount = range == ChartRange.last6Months ? 6 : 12;
    for (var i = monthCount - 1; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      labels.add(_monthAbbreviation(month.month));
      values.add(_sumForMonth(gems, month.year, month.month));
    }
  }

  final nonZeroCount = values.where((value) => value > 0).length;
  final hasEnoughData = nonZeroCount >= 2;

  return ChartTrendData(
    values: values,
    labels: labels,
    range: range,
    hasEnoughData: hasEnoughData,
  );
}

String _monthAbbreviation(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}

DateTime? _parseGemDate(String date) {
  try {
    return DateTime.tryParse(date);
  } catch (_) {
    return null;
  }
}

double _trendValue(GemstoneModel gem) {
  if (gem.isSold) {
    return gem.profit;
  }
  return gem.targetPrice;
}

double _sumForRange(List<GemstoneModel> gems, DateTime start, DateTime end) {
  final rangeStart = DateTime(start.year, start.month, start.day);
  final rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

  return gems.fold(0.0, (sum, gem) {
    final gemDate = _parseGemDate(gem.date);
    if (gemDate == null) return sum;
    if (gemDate.isBefore(rangeStart) || gemDate.isAfter(rangeEnd)) return sum;
    return sum + _trendValue(gem);
  });
}

double _sumForMonth(List<GemstoneModel> gems, int year, int month) {
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
  return _sumForRange(gems, monthStart, monthEnd);
}
