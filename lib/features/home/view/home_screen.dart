import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/features/analytics/views/analytics_screen.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/features/home/provider/home_chart_provider.dart';
import 'package:gemhub/features/home/provider/portfolio_provider.dart';

import 'package:gemhub/features/inventory/view/add_new_gemstone_inventory.dart';
import 'package:gemhub/features/jobs/view/screens/post_new_job.dart';

import 'package:gemhub/features/reports/presentation/views/reports_screen.dart';
import 'package:gemhub/shared/widgets/app_header.dart';

import 'package:gemhub/features/home/provider/profile_view_model.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);
    final portfolioAsync = ref.watch(
      portfolioDataProvider,
    );
    final chartRange = ref.watch(chartRangeProvider);
    final chartTrendAsync = ref.watch(chartTrendDataProvider);
    final heatmapAsync = ref.watch(heatmapDataProvider);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;

    return profileState.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.orange)),
      ),
      error: (err, stack) =>
          Scaffold(body: Center(child: Text("Connection Error: $err"))),
      data: (authenticatedUser) {
        if (authenticatedUser == null) {
          return const Scaffold(body: Center(child: Text("Please Log In")));
        }

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        portfolioAsync.when(
                          data: (portfolio) => _buildGoldenPortfolioCard(
                            totalInventoryValue:
                                portfolio['inventoryValue'] ?? 0.0,
                            realizedProfit: portfolio['realizedProfit'] ?? 0.0,
                            context: context,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 25),

                        // Display the username from the profile
                        const SizedBox(height: 15),
                        _buildPerformanceTrends(
                          textColor,
                          isDark,
                          chartRange,
                          chartTrendAsync,
                          ref,
                        ),
                        const SizedBox(height: 25),
                        _buildHeatmap(textColor, isDark, heatmapAsync),
                        const SizedBox(height: 25),
                        _buildQuickActions(context, isDark),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGoldenPortfolioCard({
    required double totalInventoryValue,
    required double realizedProfit,
    required BuildContext context,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppColors.primaryYellow, AppColors.accentOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CURRENT INVENTORY VALUE",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AnalyticsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.insights, // Changed icon
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "AI Insights", // Changed text
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "LKR ${NumberFormat('#,###').format(totalInventoryValue)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white30),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL REALIZED PROFIT",
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "LKR ${NumberFormat('#,###').format(realizedProfit)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  children: [
                    Text("Details"),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Performance Chart
  Widget _buildPerformanceTrends(
    Color textColor,
    bool isDark,
    ChartRange chartRange,
    AsyncValue<ChartTrendData> chartTrendAsync,
    WidgetRef ref,
  ) {
    return _buildCardWrapper(
      isDark,
      Column(
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

  // --- Heatmap Calendar ---
  Widget _buildHeatmap(
    Color textColor,
    bool isDark,
    AsyncValue<List<HeatmapCellData>> heatmapAsync,
  ) {
    return _buildCardWrapper(
      isDark,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Market Activity Heatmap",
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          heatmapAsync.when(
            data: (cells) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: 35,
                itemBuilder: (context, index) {
                  final cell = cells[index];

                  // Profit/loss gradient logic
                  Color tileColor;
                  if (cell.value > 0) {
                    // Positive value -> shades of green
                    tileColor = cell.value > 5000
                        ? AppColors.primaryGreen
                        : AppColors.successMint;
                  } else if (cell.value < 0) {
                    // Negative value -> shades of red (you can adjust this if needed)
                    tileColor = Colors.red.shade400;
                  } else {
                    // Neutral / No value
                    tileColor =
                        isDark ? Colors.grey.shade800 : Colors.grey.shade200;
                  }

                  // Fade out cells not in current month
                  if (!cell.isCurrentMonth) {
                    tileColor = tileColor.withOpacity(0.3);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: tileColor,
                      borderRadius: BorderRadius.circular(6),
                      border: !cell.isCurrentMonth
                          ? Border.all(
                              color: isDark ? Colors.white12 : Colors.black12)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${cell.date.day}',
                      style: TextStyle(
                        color: cell.isCurrentMonth
                            ? (tileColor == AppColors.primaryGreen ||
                                    tileColor == Colors.red.shade400 ||
                                    (isDark && cell.value == 0)
                                ? Colors.white
                                : Colors.black87)
                            : (isDark ? Colors.white38 : Colors.black38),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (e, st) => Center(
              child: Text(
                'Error loading heatmap',
                style: TextStyle(color: textColor),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Text(
              "Consistent profitability shown in emerald intensity",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  //  Bottom Action Buttons ---
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            Icons.add_circle,
            "Add Gem",
            "Inventory Input",
            AppColors.blueSoft,
            AppColors.accentBlue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNewGemstoneScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            Icons.business_center,
            "Post Job",
            "Hire Talent",
            AppColors.mintLight,
            AppColors.darkGreen,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String title,
    String sub,
    Color bg,
    Color iconCol,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: iconCol,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: iconCol,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              sub,
              style: TextStyle(color: iconCol.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardWrapper(bool isDark, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.textDarkAlt : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Custom Painter
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
