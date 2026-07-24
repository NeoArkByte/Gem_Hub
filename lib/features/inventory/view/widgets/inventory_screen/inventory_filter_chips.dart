import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/core/enums/gem_type.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';

/// Unified horizontal filter bar combining status and gemstone category choice chips.
class InventoryFilterChips extends ConsumerWidget {
  final bool isDark;
  final Color unselectedBg;
  final Color primaryText;
  final String selectedStatus;
  final List<String> statusFilters;
  final ValueChanged<String> onStatusSelected;

  const InventoryFilterChips({
    super.key,
    required this.isDark,
    required this.unselectedBg,
    required this.primaryText,
    required this.selectedStatus,
    required this.statusFilters,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(inventoryCategoryFilterProvider);
    final categories = GemType.values;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Status Filters (All Stock, Available, Sold)
          ...statusFilters.map((filterName) {
            final bool isSelected = selectedStatus == filterName;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filterName),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (val) {
                  if (val) onStatusSelected(filterName);
                },
                selectedColor: filterName == 'Sold'
                    ? AppColors.dangerRed
                    : AppColors.primaryGreen,
                backgroundColor: unselectedBg,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : primaryText.withOpacity(0.08),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? Colors.white : primaryText.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            );
          }),

          // Subtle Divider between Status and Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: VerticalDivider(
              color: primaryText.withOpacity(0.12),
              width: 1,
              thickness: 1,
            ),
          ),
          const SizedBox(width: 4),

          // Gemstone Categories
          ...categories.map((category) {
            final String label = category.displayName;
            final String categoryValue =
                category == GemType.allGems ? 'All' : label;
            final bool isSelected = selectedCategory == categoryValue;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (val) => ref
                    .read(inventoryCategoryFilterProvider.notifier)
                    .state = categoryValue,
                selectedColor: AppColors.primaryGreen,
                backgroundColor: unselectedBg,
                side: BorderSide(
                  color: isSelected
                      ? Colors.transparent
                      : primaryText.withOpacity(0.08),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                labelStyle: TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color:
                      isSelected ? Colors.white : primaryText.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
