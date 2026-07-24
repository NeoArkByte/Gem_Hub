import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/prediction_model.dart';

/// Reusable AI Business Prediction summary card used across Add and Update entry forms.
class InventoryPredictionCard extends StatelessWidget {
  final PredictionModel? prediction;
  final bool isLoadingPrediction;
  final Color Function(String level) confidenceColor;

  const InventoryPredictionCard({
    super.key,
    required this.prediction,
    required this.isLoadingPrediction,
    required this.confidenceColor,
  });

  @override
  Widget build(BuildContext context) {
    final confidenceLabel = prediction?.confidenceLevel ?? 'Low';
    final recordCount = prediction?.matchingRecordCount ?? 0;
    final hasData = recordCount > 0;

    if (prediction == null && !isLoadingPrediction) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(sizeFactor: animation, child: child),
      ),
      child: Card(
        key: ValueKey(
            'prediction_${isLoadingPrediction ? 'loading' : recordCount}'),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights_outlined,
                      size: 20,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    '📊 Business Prediction',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (isLoadingPrediction) ...[
                const SizedBox(height: 4),
                const LinearProgressIndicator(minHeight: 2),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Calculating prediction…',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 8),
              ] else if (!hasData) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.amber),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No sufficient historical records available for prediction.',
                          style: TextStyle(fontSize: 12, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Text(
                  'Based on $recordCount similar inventory records',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                _buildPredictionMetric(
                  'Expected Selling Price',
                  prediction!.expectedSellingPrice,
                  icon: Icons.attach_money,
                  isCurrency: true,
                ),
                _buildPredictionMetric(
                  'Expected Expenses',
                  prediction!.expectedExpenses,
                  icon: Icons.receipt_long,
                  isCurrency: true,
                ),
                _buildPredictionMetric(
                  'Expected Profit',
                  prediction!.expectedProfit,
                  icon: Icons.trending_up,
                  isCurrency: true,
                  valueColor: prediction!.expectedProfit >= 0
                      ? AppColors.successGreen
                      : AppColors.accentRed,
                ),
                _buildPredictionMetric(
                  'Expected Selling Time',
                  prediction!.expectedDaysToSell,
                  icon: Icons.schedule,
                  suffix: ' days',
                  isCurrency: false,
                ),
                _buildPredictionMetric(
                  'Avg. Profit Margin',
                  prediction!.profitMarginPercent,
                  icon: Icons.percent,
                  suffix: '%',
                  isCurrency: false,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 16,
                          color: confidenceColor(confidenceLabel),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Confidence Level',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            confidenceColor(confidenceLabel).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: confidenceColor(confidenceLabel)
                              .withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        confidenceLabel,
                        style: TextStyle(
                          color: confidenceColor(confidenceLabel),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionMetric(
    String label,
    double value, {
    String suffix = '',
    IconData? icon,
    bool isCurrency = true,
    Color? valueColor,
  }) {
    final String displayValue = isCurrency
        ? NumberFormat.currency(locale: 'en_LK', symbol: 'Rs. ')
            .format(value.toInt())
        : '${value.toStringAsFixed(1)}$suffix';

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Text(
            displayValue,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
