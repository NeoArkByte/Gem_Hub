import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:gemhub/features/inventory/view/add_new_gemstone_inventory.dart';
import 'package:go_router/go_router.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final List<String> _categories = [
    'All',
    'Ruby',
    'Sapphire',
    'Emerald',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryViewModelProvider);
    final filteredGems = ref.watch(filteredInventoryProvider);
    final secondaryTextColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    // 1. Detect Theme Mode
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Define Dynamic Colors
    Color scaffoldBg =
        isDark ? AppColors.darkBackground : AppColors.lightBackgroundGrey;
    Color cardBg = isDark ? AppColors.darkSurface : Colors.white;
    Color primaryTextColor = isDark ? Colors.white : AppColors.darkBackground;

    return inventoryAsync.when(
      data: (_) {
        return Scaffold(
          backgroundColor: scaffoldBg,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(primaryTextColor, cardBg),
                _buildSearchBar(isDark),
                _buildCategoryFilters(isDark),
                Expanded(
                  child: filteredGems.isEmpty
                      ? Center(
                          child: Text(
                            "No gemstones found",
                            style: TextStyle(color: secondaryTextColor),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredGems.length,
                          itemBuilder: (context, index) => _buildGemCard(
                            filteredGems[index],
                            cardBg,
                            primaryTextColor,
                            secondaryTextColor,
                            context,
                            ref,
                          ),
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddNewGemstoneScreen(),
              ),
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  // Confirmation Dialog before deleting a gemstone from the database
  void _confirmDelete(BuildContext context, GemstoneModel gem, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Delete Gemstone?"),
        content: Text(
          "Are you sure you want to remove this ${gem.variety} from your inventory?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(inventoryViewModelProvider.notifier)
                  .deleteGemstone(gem.id!);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color textColor, Color cardBg) {
    // Add these parameters
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Inventory",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor, // Use the parameter here
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cardBg, // Use the parameter here
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tune, color: AppColors.darkSurfaceAlt),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (val) =>
            ref.read(inventorySearchQueryProvider.notifier).state = val,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: 'Search gemstones...',
          filled: true,
          fillColor: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    final selectedCategory = ref.watch(inventoryCategoryFilterProvider);

    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          bool isSelected = selectedCategory == _categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: ChoiceChip(
              label: Text(_categories[index]),
              selected: isSelected,
              onSelected: (val) => ref
                  .read(inventoryCategoryFilterProvider.notifier)
                  .state = _categories[index],
              backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGemCard(
    GemstoneModel gem,
    Color cardBg,
    Color textColor,
    Color subTextColor,
    BuildContext context,
    WidgetRef ref,
  ) {
    return InkWell(
      // Trigger the detail sheet when the entire card is tapped
      onTap: () => context.pushNamed('inventory_details', extra: gem),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Image & Action Overlay ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: (() {
                    final imagePath = gem.firstImagePath ?? gem.finalImagePath;

                    if (imagePath != null) {
                      return Image.file(
                        File(imagePath),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      );
                    }
                    return Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  })(),
                ),
                // Status Badge (Available/Sold)
                Positioned(
                  top: 12,
                  left: 12,
                  child: _buildStatusBadge(
                    gem.sellingPrice > 0 ? "SOLD" : "AVAILABLE",
                  ),
                ),
                // Edit/Delete Menu (Modern Three-Dot Menu)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: textColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Navigate to the same screen used for adding, but pass the current gem
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AddNewGemstoneScreen(gemstoneToEdit: gem),
                            ),
                          );
                        } else if (value == 'delete') {
                          // Trigger your deletion logic
                          _confirmDelete(context, gem, ref);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_outlined,
                                size: 20,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 12),
                              Text("Edit Details"),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 12),
                              Text(
                                "Remove Item",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- Details Section ---
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${gem.finalWeight}ct ${gem.variety}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${gem.color} • ${gem.treatmentCost > 0 ? 'Treated' : 'Unheated'}",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Rs. ${gem.targetPrice.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for the "SOLD" or "AVAILABLE" badge on the top-left of the image
  Widget _buildStatusBadge(String status) {
    final bool isSold = status == "SOLD";
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isSold
            // ignore: deprecated_member_use
            ? Colors.red.withOpacity(0.9)
            // ignore: deprecated_member_use
            : AppColors.primaryGreen.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
