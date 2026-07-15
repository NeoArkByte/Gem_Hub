import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/shared/widgets/custom_confirm_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/core/enums/gem_type.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:gemhub/features/inventory/view/add_new_gemstone_inventory.dart';
import 'package:gemhub/features/inventory/view/auction_section_widget.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  // Available and sold filters
  final List<String> _statusFilters = ['All Stock', 'Available', 'Sold'];
  String _selectedStatus = 'All Stock';

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryViewModelProvider);
    final filteredGems = ref.watch(filteredInventoryProvider);

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Core design system tokens
    final Color scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackgroundGrey;
    final Color surfaceBg = isDark ? AppColors.darkSurface : Colors.white;
    final Color surfaceBgAlt =
        isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder;
    final Color primaryText = isDark ? Colors.white : AppColors.darkBackground;
    final Color secondaryText = primaryText.withOpacity(0.55);

    return inventoryAsync.when(
      data: (_) {
        // Separate gems locally to calculate real-time portfolio analytics
        final availableGems =
            filteredGems.where((gem) => gem.sellingPrice <= 0).toList();
        final soldGems =
            filteredGems.where((gem) => gem.sellingPrice > 0).toList();

        final double activeValuation = availableGems.fold<double>(
            0.0, (sum, gem) => sum + gem.targetPrice);

        // Apply our availability state filters to the view layout
        List<GemstoneModel> displayGems = filteredGems;
        if (_selectedStatus == 'Available') {
          displayGems = availableGems;
        } else if (_selectedStatus == 'Sold') {
          displayGems = soldGems;
        }

        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(primaryText, surfaceBg),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              _buildSnapshotCard(
                                availableCount: availableGems.length,
                                soldCount: soldGems.length,
                                activeValuation: activeValuation,
                                textColor: primaryText,
                                subTextColor: secondaryText,
                                isDark: isDark,
                              ),
                              if (filteredGems
                                  .where((gem) =>
                                      gem.isReadyToSale &&
                                      gem.sellingPrice <= 0)
                                  .isNotEmpty) ...[
                                const SizedBox(height: 16),
                                AuctionSectionWidget(
                                  auctionGems: filteredGems
                                      .where((gem) =>
                                          gem.isReadyToSale &&
                                          gem.sellingPrice <= 0)
                                      .toList(),
                                  isDark: isDark,
                                  primaryText: primaryText,
                                  secondaryText: secondaryText,
                                  surfaceBg: surfaceBg,
                                ),
                              ],
                              const SizedBox(height: 16),
                              _buildSearchBar(
                                  isDark, primaryText, surfaceBgAlt),
                              const SizedBox(height: 12),
                              _buildUnifiedFilters(
                                  isDark, surfaceBg, primaryText),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      if (displayGems.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            child: _buildEmptyState(secondaryText),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.68,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _buildGemCard(
                                gem: displayGems[index],
                                cardBg: surfaceBg,
                                textColor: primaryText,
                                subTextColor: secondaryText,
                                isDark: isDark,
                              ),
                              childCount: displayGems.length,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryGreen,
            elevation: 4,
            highlightElevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewGemstoneScreen(),
              ),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
      error: (err, stack) => Center(
        child: Text(
          'Error loading inventory: $err',
          style: const TextStyle(
              color: AppColors.dangerRed, fontFamily: 'Hanken Grotesk'),
        ),
      ),
    );
  }

  // Header Component
  Widget _buildHeader(Color textColor, Color cardBg) {
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

  // Refined Snapshot Card featuring pure Available vs Sold stock performance metrics
  Widget _buildSnapshotCard({
    required int availableCount,
    required int soldCount,
    required double activeValuation,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(isDark ? 0.15 : 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(isDark ? 0.04 : 0.02),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ACTIVE PORTFOLIO VALUE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: subTextColor,
                      letterSpacing: 1.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Rs. ${activeValuation.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryGreen,
                      fontFamily: 'Hanken Grotesk',
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_outlined,
                    color: AppColors.primaryGreen, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "AVAILABLE STOCK",
                    style: TextStyle(
                        fontSize: 10,
                        color: subTextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$availableCount Gems",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        fontFamily: 'Hanken Grotesk'),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "SOLD INVENTORY",
                    style: TextStyle(
                        fontSize: 10,
                        color: subTextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        fontFamily: 'Inter'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$soldCount Gems",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dangerRed,
                        fontFamily: 'Hanken Grotesk'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Premium Search Text Field Element
  Widget _buildSearchBar(bool isDark, Color primaryText, Color fillColor) {
    return TextField(
      onChanged: (val) =>
          ref.read(inventorySearchQueryProvider.notifier).state = val,
      style: TextStyle(
          color: primaryText, fontFamily: 'Hanken Grotesk', fontSize: 16),
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
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }

  // Unified Filter Bar combining Status and Category
  Widget _buildUnifiedFilters(
      bool isDark, Color unselectedBg, Color primaryText) {
    final selectedCategory = ref.watch(inventoryCategoryFilterProvider);
    final categories = GemType.values;

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Status Filters
          ..._statusFilters.map((filterName) {
            final bool isSelected = _selectedStatus == filterName;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filterName),
                selected: isSelected,
                showCheckmark: false,
                onSelected: (val) {
                  if (val) setState(() => _selectedStatus = filterName);
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
                    borderRadius: BorderRadius.circular(12)),
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
                    borderRadius: BorderRadius.circular(12)),
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

  // Interactive Luxury Gemstone Card Integration
  Widget _buildGemCard({
    required GemstoneModel gem,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    final bool isSold = gem.sellingPrice > 0;

    return Opacity(
      opacity: isSold ? 0.85 : 1.0,
      child: GestureDetector(
        onTap: () => context.pushNamed('inventory_details', extra: gem),
        child: Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark
                  ? AppColors.darkSurfaceAlt
                  : Colors.black.withOpacity(0.03),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top: Image Section
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(28)),
                      child: _buildCardImage(
                          gem.firstImagePath ?? gem.finalImagePath,
                          isDark,
                          textColor),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildCardMenu(gem, cardBg, textColor),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildStatusBadge(isSold ? "SOLD" : "AVAILABLE"),
                    ),
                  ],
                ),
              ),

              // Bottom: Organized Info Section
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row: Variety + Weight Tag
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            gem.variety,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${gem.finalWeight} CT',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Sub-descriptor: Color
                    Text(
                      gem.color,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Price Tag
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Rs. ${(isSold ? gem.sellingPrice : gem.targetPrice).toStringAsFixed(0)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Media Render Image Frame
  Widget _buildCardImage(String? imagePath, bool isDark, Color textColor) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return Image.file(
        File(imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
      child: Icon(Icons.diamond_outlined,
          size: 40, color: textColor.withOpacity(0.15)),
    );
  }

  // Corner Options Action Menu Dropdown Button
  Widget _buildCardMenu(GemstoneModel gem, Color cardBg, Color textColor) {
    return Container(
      height: 34,
      width: 34,
      decoration: BoxDecoration(
        color: cardBg.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded, color: textColor, size: 18),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        color: cardBg,
        elevation: 8,
        onSelected: (value) {
          if (value == 'edit') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddNewGemstoneScreen(gemstoneToEdit: gem)),
            );
          } else if (value == 'delete') {
            _confirmDelete(context, gem, ref);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primaryGreen),
                const SizedBox(width: 10),
                const Text("Edit Details",
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.dangerRed),
                const SizedBox(width: 10),
                const Text("Remove",
                    style: TextStyle(
                        color: AppColors.dangerRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Inter')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Status Mapped Pill Badges
  Widget _buildStatusBadge(String status) {
    final bool isSold = status == "SOLD";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isSold
            ? AppColors.dangerRed.withOpacity(0.9)
            : AppColors.primaryGreen.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: (isSold ? AppColors.dangerRed : AppColors.primaryGreen)
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                fontFamily: 'Inter'),
          ),
        ],
      ),
    );
  }

  // Fallback Graphic Placeholder Layer
  Widget _buildEmptyState(Color secondaryText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 48, color: secondaryText.withOpacity(0.3)),
            const SizedBox(height: 12),
            Text(
              "No gemstones match criteria",
              style: TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter'),
            ),
          ],
        ),
      ),
    );
  }

  // Security Core Modal For Clean Data Clearances
  void _confirmDelete(BuildContext context, GemstoneModel gem, WidgetRef ref) {
    showDialog<bool>(
      context: context,
      builder: (context) => CustomConfirmDialog(
        title: "Delete Gemstone?",
        content:
            "Are you sure you want to permanently remove this ${gem.variety} from your inventory?",
        confirmLabel: "Delete",
        cancelLabel: "Cancel",
        confirmColor: AppColors.dangerRed,
        icon: Icons.delete_outline_rounded,
      ),
    ).then((isConfirmed) {
      if (isConfirmed == true && gem.id != null) {
        ref.read(inventoryViewModelProvider.notifier).deleteGemstone(gem.id!);
      }
    });
  }
}
