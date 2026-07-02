import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_chart_provider.g.dart';

enum ChartRange {
  days7,
  days28,
  days90,
  days365,
  currentMonth,
  lastMonth,
  twoMonthsAgo,
  currentYear,
  lastYear,
  lifetime,
}

extension ChartRangeLabel on ChartRange {
  String get displayName {
    final now = DateTime.now();
    switch (this) {
      case ChartRange.days7:
        return '7D';
      case ChartRange.days28:
        return '28D';
      case ChartRange.days90:
        return '90D';
      case ChartRange.days365:
        return '365D';
      case ChartRange.currentMonth:
        return _monthAbbrevSafe(now.month);
      case ChartRange.lastMonth:
        return _monthAbbrevSafe(now.month - 1);
      case ChartRange.twoMonthsAgo:
        return _monthAbbrevSafe(now.month - 2);
      case ChartRange.currentYear:
        return '${now.year}';
      case ChartRange.lastYear:
        return '${now.year - 1}';
      case ChartRange.lifetime:
        return 'Lifetime';
    }
  }
}

String _monthAbbrevSafe(int month) {
  int m = month;
  while (m <= 0) {
    m += 12;
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return months[m - 1];
}

final chartRangeProvider = StateProvider<ChartRange>(
  (ref) => ChartRange.days365,
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

class HeatmapCellData {
  final DateTime date;
  final bool isCurrentMonth;
  final double value;

  HeatmapCellData({
    required this.date,
    required this.isCurrentMonth,
    required this.value,
  });
}

@riverpod
Future<ChartTrendData> chartTrendData(Ref ref) async {
  final gems = await ref.watch(inventoryViewModelProvider.future);
  final range = ref.watch(chartRangeProvider);

  final now = DateTime.now();
  final List<String> labels = [];
  final List<double> values = [];

  void addWeeksForMonth(int year, int month) {
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    const weeks = 4;
    final weekLength = (lastDayOfMonth.day / weeks).ceil();

    for (var i = 0; i < weeks; i++) {
      final segmentStart = firstDayOfMonth.add(Duration(days: i * weekLength));
      final segmentEnd = DateTime(
        year,
        month,
        min(lastDayOfMonth.day, (i + 1) * weekLength),
      );
      labels.add('W${i + 1}');
      values.add(_sumForRange(gems, segmentStart, segmentEnd));
    }
  }

  void addMonthsForYear(int year) {
    for (var i = 1; i <= 12; i++) {
      labels.add(_monthAbbreviation(i));
      values.add(_sumForMonth(gems, year, i));
    }
  }

  switch (range) {
    case ChartRange.days7:
      for (var i = 6; i >= 0; i--) {
        final d = now.subtract(Duration(days: i));
        labels.add('${d.day}/${d.month}');
        values.add(_sumForRange(gems, d, d));
      }
      break;
    case ChartRange.days28:
      for (var i = 3; i >= 0; i--) {
        final end = now.subtract(Duration(days: i * 7));
        final start = end.subtract(const Duration(days: 6));
        labels.add('W${4 - i}');
        values.add(_sumForRange(gems, start, end));
      }
      break;
    case ChartRange.days90:
      for (var i = 11; i >= 0; i--) {
        final end = now.subtract(Duration(days: (i * 90) ~/ 12));
        final start = now.subtract(Duration(days: ((i + 1) * 90) ~/ 12 - 1));
        labels.add('');
        values.add(_sumForRange(gems, start, end));
      }
      break;
    case ChartRange.days365:
      for (var i = 11; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        labels.add(_monthAbbreviation(month.month));
        values.add(_sumForMonth(gems, month.year, month.month));
      }
      break;
    case ChartRange.currentMonth:
      addWeeksForMonth(now.year, now.month);
      break;
    case ChartRange.lastMonth:
      final d = DateTime(now.year, now.month - 1, 1);
      addWeeksForMonth(d.year, d.month);
      break;
    case ChartRange.twoMonthsAgo:
      final d = DateTime(now.year, now.month - 2, 1);
      addWeeksForMonth(d.year, d.month);
      break;
    case ChartRange.currentYear:
      addMonthsForYear(now.year);
      break;
    case ChartRange.lastYear:
      addMonthsForYear(now.year - 1);
      break;
    case ChartRange.lifetime:
      if (gems.isEmpty) {
        labels.add('${now.year}');
        values.add(0);
      } else {
        var minYear = now.year;
        for (final g in gems) {
          final d = _parseGemDate(g.recordDate);
          if (d != null && d.year < minYear) {
            minYear = d.year;
          }
        }
        for (var y = minYear; y <= now.year; y++) {
          labels.add('$y');
          var sum = 0.0;
          for (var m = 1; m <= 12; m++) {
            sum += _sumForMonth(gems, y, m);
          }
          values.add(sum);
        }
      }
      break;
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

@riverpod
Future<List<HeatmapCellData>> heatmapData(Ref ref) async {
  final gems = await ref.watch(inventoryViewModelProvider.future);
  final now = DateTime.now();
  final firstDay = DateTime(now.year, now.month, 1);
  final startDate = firstDay.subtract(Duration(days: firstDay.weekday % 7));

  List<HeatmapCellData> cells = [];
  for (int i = 0; i < 35; i++) {
    final day = startDate.add(Duration(days: i));
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    final val = _profitForRange(gems, start, end);

    cells.add(HeatmapCellData(
      date: day,
      isCurrentMonth: day.month == now.month,
      value: val,
    ));
  }
  return cells;
}

String _monthAbbreviation(int month) {
  int m = month;
  while (m <= 0) {
    m += 12;
  }
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
  return months[m - 1];
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
    return gem.actualProfit;
  }
  return gem.salesTargetPrice;
}

double _sumForRange(List<GemstoneModel> gems, DateTime start, DateTime end) {
  final rangeStart = DateTime(start.year, start.month, start.day);
  final rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

  return gems.fold(0.0, (sum, gem) {
    final gemDate = _parseGemDate(gem.recordDate);
    if (gemDate == null) return sum;
    if (gemDate.isBefore(rangeStart) || gemDate.isAfter(rangeEnd)) return sum;
    return sum + _trendValue(gem);
  });
}

double _profitForRange(List<GemstoneModel> gems, DateTime start, DateTime end) {
  final rangeStart = DateTime(start.year, start.month, start.day);
  final rangeEnd = DateTime(end.year, end.month, end.day, 23, 59, 59);

  return gems.fold(0.0, (sum, gem) {
    if (!gem.isSold) return sum;
    final gemDate = _parseGemDate(gem.recordDate);
    if (gemDate == null) return sum;
    if (gemDate.isBefore(rangeStart) || gemDate.isAfter(rangeEnd)) return sum;
    return sum + gem.actualProfit;
  });
}

double _sumForMonth(List<GemstoneModel> gems, int year, int month) {
  final monthStart = DateTime(year, month, 1);
  final monthEnd = DateTime(year, month + 1, 0, 23, 59, 59);
  return _sumForRange(gems, monthStart, monthEnd);
}
