import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';

/// Styled search text field connected to inventorySearchQueryProvider.
class InventorySearchBar extends ConsumerWidget {
  final bool isDark;
  final Color primaryText;
  final Color fillColor;

  const InventorySearchBar({
    super.key,
    required this.isDark,
    required this.primaryText,
    required this.fillColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (val) =>
          ref.read(inventorySearchQueryProvider.notifier).state = val,
      style: TextStyle(
        color: primaryText,
        fontFamily: 'Hanken Grotesk',
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Search gemstones...',
        hintStyle: TextStyle(color: primaryText.withOpacity(0.35)),
        prefixIcon:
            Icon(Icons.search_rounded, color: primaryText.withOpacity(0.4)),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}
