// lib/features/analytics/view/screens/analytics_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gemhub/data/models/analytics/analytics_data_model.dart';
import 'package:gemhub/features/analytics/viewmodels/analytics_viewmodel.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(analyticsViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Analytics & Insights'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () {
              // TODO: Implement Filter Bottom Sheet to trigger ref.read(analyticsViewModelProvider.notifier).loadAnalytics(filterGemType: 'Sapphire');
            },
          )
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInsightsCards(state.businessInsights),
                  const SizedBox(height: 24),
                  _buildSummaryGrid(state.summary),
                  const SizedBox(height: 24),
                  const Text("Monthly Revenue vs Profit",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildMonthlyChart(state.monthlyData),
                ],
              ),
            ),
    );
  }

  Widget _buildInsightsCards(List<String> insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AI Business Insights",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...insights
            .map((insight) => Card(
                  color: Colors.blue.withOpacity(0.1),
                  child: ListTile(
                    leading: const Icon(Icons.auto_awesome, color: Colors.blue),
                    title: Text(insight),
                  ),
                )),
      ],
    );
  }

  Widget _buildSummaryGrid(BusinessSummary? summary) {
    if (summary == null) return const SizedBox();

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _statBox("Total Profit",
            "LKR ${summary.totalProfit.toStringAsFixed(0)}", Colors.green),
        _statBox("Total Revenue",
            "LKR ${summary.totalRevenue.toStringAsFixed(0)}", Colors.blue),
        _statBox(
            "Avg Selling Time",
            "${summary.averageSellingTime.toStringAsFixed(1)} Days",
            Colors.orange),
        _statBox("Items Sold", "${summary.totalInventorySold}", Colors.purple),
      ],
    );
  }

  Widget _statBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(List<MonthlyPerformance> data) {
    if (data.isEmpty) return const Text("Not enough data to display chart.");

    return AspectRatio(
      aspectRatio: 1.5,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: data
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.profit))
                  .toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              isStrokeCapRound: true,
              belowBarData:
                  BarAreaData(show: true, color: Colors.green.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }
}
