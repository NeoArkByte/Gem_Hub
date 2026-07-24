import 'package:flutter/material.dart';

/// Clean top bar header for the Gem Inventory screen.
class InventoryHeader extends StatelessWidget {
  final Color textColor;

  const InventoryHeader({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Gem Inventory",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: textColor,
              fontFamily: 'Hanken Grotesk',
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 1),
        ],
      ),
    );
  }
}
