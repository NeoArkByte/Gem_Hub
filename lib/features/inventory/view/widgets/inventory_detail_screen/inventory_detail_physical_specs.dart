import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';

/// Grid displaying gemstone physical specifications (Weight, Color, Type, Buy Weight).
class InventoryDetailPhysicalSpecs extends StatelessWidget {
  final GemstoneModel gemstone;

  const InventoryDetailPhysicalSpecs({
    super.key,
    required this.gemstone,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Physical Specs',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            Icon(Icons.info_outline, color: subtitleColor, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildSpecCard(
              context,
              Icons.scale,
              'WEIGHT (Final)',
              '${gemstone.finalWeight} ct',
              AppColors.primaryBlue,
            ),
            _buildSpecCard(
              context,
              Icons.palette,
              'COLOR',
              gemstone.color,
              AppColors.primaryGreen,
            ),
            _buildSpecCard(
              context,
              Icons.diamond,
              'TYPE',
              gemstone.isRough ? 'Rough' : 'Cut',
              AppColors.accentGreen,
            ),
            _buildSpecCard(
              context,
              Icons.shopping_bag,
              'BUY WEIGHT',
              '${gemstone.buyingWeight} ct',
              AppColors.darkSurfaceAlt,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color accentColor,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color labelColor =
        isDark ? AppColors.greyTextMutedLight : AppColors.greyText;
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(isDark ? 0.4 : 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
