import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';

/// Top header banner displaying gem variety name, inventory ID, and formatted date tag.
class InventoryDetailHeader extends StatelessWidget {
  final GemstoneModel gemstone;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;
  final Color borderColor;
  final String formattedDate;

  const InventoryDetailHeader({
    super.key,
    required this.gemstone,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
    required this.borderColor,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gemstone.variety,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inventory ID: #${gemstone.id ?? "N/A"}',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today,
                color: AppColors.primaryGreen,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                formattedDate,
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
