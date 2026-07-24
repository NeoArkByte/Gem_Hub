import 'package:flutter/material.dart';

/// Fallback visual widget shown when no gemstones match the selected filters or search query.
class InventoryEmptyState extends StatelessWidget {
  final Color secondaryText;

  const InventoryEmptyState({
    super.key,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: secondaryText.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "No gemstones match criteria",
              style: TextStyle(
                color: secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
