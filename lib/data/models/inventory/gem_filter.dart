import 'package:flutter/material.dart';

class GemFilter {
  final String? variety;
  final DateTimeRange? dateRange;
  final String? status; // 'All', 'Sold', 'Available'

  GemFilter({this.variety, this.dateRange, this.status});

  bool get isEmpty => variety == null && dateRange == null && (status == null || status == 'All');

  GemFilter copyWith({
    String? variety,
    DateTimeRange? dateRange,
    String? status,
  }) {
    return GemFilter(
      variety: variety ?? this.variety,
      dateRange: dateRange ?? this.dateRange,
      status: status ?? this.status,
    );
  }
}