import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/home/provider/home_chart_provider.dart';
import 'package:gemhub/features/home/view/widgets/card_wrapper.dart';

class PerformanceTrendsCard extends ConsumerWidget {
  final Color textColor;
  final bool isDark;
  final ChartRange chartRange;
  final AsyncValue<ChartTrendData> chartTrendAsync;

  const PerformanceTrendsCard({
    super.key,
    required this.textColor,
    required this.isDark,
    required this.chartRange,
    required this.chartTrendAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return HomeCardWrapper(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Performance Trends",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<ChartRange>(
                  value: chartRange,
                  icon: Icon(Icons.keyboard_arrow_down,
                      color: Colors.blue.shade700),
                  isDense: true,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (ChartRange? newValue) {
                    if (newValue != null) {
                      ref.read(chartRangeProvider.notifier).state = newValue;
                    }
                  },
                  items: ChartRange.values.map((ChartRange range) {
                    return DropdownMenuItem<ChartRange>(
                      value: range,
                      child: Text(range.displayName),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            width: double.infinity,
            child: chartTrendAsync.when(
              data: (trend) {
                if (!trend.hasEnoughData) {
                  return Center(
                    child: Text(
                      'Not enough data to display the chart.',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                  );
                }
                return CustomPaint(
                  painter: TrendChartPainter(
                    values: trend.values,
                    lineColor: AppColors.accentBlue,
                    fillColor: AppColors.accentBlue.withOpacity(0.18),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => Center(
                child: Text(
                  'Error loading chart data',
                  style: TextStyle(color: Colors.red.shade400),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          chartTrendAsync.when(
            data: (trend) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: trend.labels
                    .map(
                      (label) => Expanded(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class TrendChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color fillColor;

  TrendChartPainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double padding = 16;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final maxValue =
        values.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);

    for (var row = 0; row < 3; row++) {
      final dy = padding + chartHeight / 3 * row;
      canvas.drawLine(
        Offset(padding, dy),
        Offset(size.width - padding, dy),
        gridPaint,
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = padding + (chartWidth / (values.length - 1)) * i;
      final y = padding + chartHeight * (1 - (values[i] / maxValue));
      points.add(Offset(x, y));
    }

    final trendPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var point in points.skip(1)) {
      trendPath.lineTo(point.dx, point.dy);
    }

    final fillPath = Path.from(trendPath)
      ..lineTo(points.last.dx, size.height - padding)
      ..lineTo(points.first.dx, size.height - padding)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(trendPath, paint);

    final dotPaint = Paint()..color = lineColor;
    for (var point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}
