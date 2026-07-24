import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:gemhub/features/inventory/view/screens/inventory_add_entry_screen.dart';
import 'package:gemhub/features/inventory/view/widgets/auction_section_widget.dart';
import 'package:gemhub/features/inventory/view/widgets/inventory_screen/inventory_screen_widgets.dart';

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

        // Apply availability state filters to the view layout
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
                InventoryHeader(textColor: primaryText),
                Expanded(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              InventorySnapshotCard(
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
                              InventorySearchBar(
                                isDark: isDark,
                                primaryText: primaryText,
                                fillColor: surfaceBgAlt,
                              ),
                              const SizedBox(height: 12),
                              InventoryFilterChips(
                                isDark: isDark,
                                unselectedBg: surfaceBg,
                                primaryText: primaryText,
                                selectedStatus: _selectedStatus,
                                statusFilters: _statusFilters,
                                onStatusSelected: (status) {
                                  setState(() => _selectedStatus = status);
                                },
                              ),
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
                            child: InventoryEmptyState(
                              secondaryText: secondaryText,
                            ),
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
                              (context, index) => InventoryGemCard(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InventoryAddEntryScreen(),
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
            color: AppColors.dangerRed,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
      ),
    );
  }
}
