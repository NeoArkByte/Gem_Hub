import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';

/// Investment financial breakdown card detailing buying price, value additions, certificates, and profit metrics.
class InventoryDetailInvestmentCard extends StatelessWidget {
  final GemstoneModel gemstone;
  final String Function(double) formatCurrency;

  const InventoryDetailInvestmentCard({
    super.key,
    required this.gemstone,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    final totalInvested = gemstone.totalFinalCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor.withOpacity(isDark ? 0.4 : 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInvestmentRow(
                      context,
                      'Buying Price',
                      formatCurrency(gemstone.buyingPrice),
                      isBold: true,
                    ),
                    if (gemstone.valueAdditions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Value Additions',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...gemstone.valueAdditions.map((va) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildInvestmentRow(
                            context,
                            '${va.costType.displayName}${va.treatmentName.isNotEmpty ? ' (${va.treatmentName})' : ''}',
                            formatCurrency(va.cost),
                          ),
                        );
                      }),
                    ],
                    if (gemstone.certificates.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Certificates',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...gemstone.certificates.map((cert) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: _buildInvestmentRow(
                            context,
                            'Certificate (${cert.labName})',
                            formatCurrency(cert.certificateFees),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildInvestmentRow(
                      context,
                      'Target Valuation',
                      formatCurrency(gemstone.salesTargetPrice),
                    ),
                    const SizedBox(height: 12),
                    if (gemstone.isSold)
                      _buildInvestmentRow(
                        context,
                        'Actual Sold Price',
                        formatCurrency(gemstone.actualSoldPrice),
                      ),
                    if (gemstone.isSold) const SizedBox(height: 12),
                    _buildInvestmentRow(
                      context,
                      gemstone.isSold ? 'Actual Profit' : 'Projected Profit',
                      formatCurrency(gemstone.isSold
                          ? gemstone.actualProfit
                          : gemstone.targetProfit),
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildInvestmentRow(
                      context,
                      gemstone.isSold ? 'Actual Margin' : 'Target Margin',
                      '${(gemstone.isSold ? gemstone.actualMargin : gemstone.targetMargin).toStringAsFixed(1)}%',
                      isMuted: true,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryGreen.withOpacity(isDark ? 0.05 : 0.08),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.2),
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Invested',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      formatCurrency(totalInvested),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
    bool isMuted = false,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;

    return Opacity(
      opacity: isMuted ? 0.6 : 1.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
