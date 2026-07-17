import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';

class PredictionSheet extends StatelessWidget {
  const PredictionSheet({
    super.key,
    required this.prediction,
    required this.isLoading,
    required this.confidenceColor,
  });

  final PredictionModel? prediction;
  final bool isLoading;
  final Color Function(String) confidenceColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final recordCount = prediction?.matchingRecordCount ?? 0;
    final hasData = recordCount > 0;
    final confidenceLabel = prediction?.confidenceLevel ?? 'Low';

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // ── Header ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📊 Business Prediction',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 17)),
                        Text('AI-powered market analysis',
                            style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            // ── Scrollable content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: _buildContent(
                    context, hasData, recordCount, confidenceLabel, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool hasData, int recordCount,
      String confidenceLabel, bool isDark) {
    // ── Loading ─────────────────────────────────────────────────────────────
    if (isLoading) {
      return Column(
        children: [
          const SizedBox(height: 32),
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text('Analysing historical records…',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const SizedBox(height: 8),
          const LinearProgressIndicator(),
        ],
      );
    }

    // ── No data ─────────────────────────────────────────────────────────────
    if (!hasData) {
      return Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.35)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 36),
                const SizedBox(height: 12),
                const Text(
                  'No sufficient historical records available for prediction.',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 13, height: 1.6, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add more sold inventory records to improve accuracy.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // ── Has data ────────────────────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Record count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Text(
            'Based on $recordCount similar inventory records',
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 20),
        // Metric cards
        _metricCard(
          label: 'Expected Selling Price',
          value: prediction!.expectedSellingPrice,
          icon: Icons.attach_money,
          isCurrency: true,
          color: AppColors.primaryBlue,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Expected Expenses',
          value: prediction!.expectedExpenses,
          icon: Icons.receipt_long,
          isCurrency: true,
          color: AppColors.accentOrange,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Expected Profit',
          value: prediction!.expectedProfit,
          icon: Icons.trending_up,
          isCurrency: true,
          color: prediction!.expectedProfit >= 0
              ? AppColors.successGreen
              : AppColors.accentRed,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Expected Selling Time',
          value: prediction!.expectedDaysToSell,
          icon: Icons.schedule,
          isCurrency: false,
          suffix: ' days',
          color: AppColors.accentPurple,
        ),
        const SizedBox(height: 10),
        _metricCard(
          label: 'Avg. Profit Margin',
          value: prediction!.profitMarginPercent,
          icon: Icons.percent,
          isCurrency: false,
          suffix: '%',
          color: AppColors.primaryYellow,
        ),
        const SizedBox(height: 24),
        // Confidence row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: confidenceColor(confidenceLabel).withOpacity(0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: confidenceColor(confidenceLabel).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.shield_outlined,
                  color: confidenceColor(confidenceLabel), size: 22),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Confidence Level',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color:
                      confidenceColor(confidenceLabel).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        confidenceColor(confidenceLabel).withOpacity(0.5),
                  ),
                ),
                child: Text(
                  confidenceLabel,
                  style: TextStyle(
                    color: confidenceColor(confidenceLabel),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required double value,
    required IconData icon,
    required Color color,
    bool isCurrency = true,
    String suffix = '',
  }) {
    final displayValue = isCurrency
        ? NumberFormat.currency(locale: 'en_LK', symbol: 'Rs. ')
            .format(value.toInt())
        : '${value.toStringAsFixed(1)}$suffix';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
