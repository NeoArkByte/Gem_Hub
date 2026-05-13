import 'package:flutter/material.dart';

class GemFilter {
  final String? variety; // Changed from gemType to match your model
  final DateTimeRange? dateRange;

  GemFilter({this.variety, this.dateRange});

  // Helper to check if the filter is empty
  bool get isEmpty => variety == null && dateRange == null;

  GemFilter copyWith({
    String? variety,
    DateTimeRange? dateRange,
  }) {
    return GemFilter(
      variety: variety ?? this.variety,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}