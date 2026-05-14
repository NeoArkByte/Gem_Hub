import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_market/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:job_market/data/models/inventory/gemstone_model.dart';
import 'package:job_market/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:job_market/features/inventory/view/add_new_gemstone_inventory.dart';

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
    Color scaffoldBg = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackgroundGrey;
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
              onSelected: (val) =>
                  ref.read(inventoryCategoryFilterProvider.notifier).state =
                      _categories[index],
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
      onTap: () => _showGemDetails(context, gem),
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
                  child: gem.finalImagePath != null
                      ? Image.file(
                          File(gem.finalImagePath!),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
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

  Widget _buildDetailGrid(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: items,
    );
  }

  Widget _detailItem(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceAlt
            : AppColors.lightBackgroundSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(
    String label,
    String value,
    Color subColor,
    Color valColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: subColor)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valColor),
          ),
        ],
      ),
    );
  }

  void _showGemDetails(BuildContext context, GemstoneModel gem) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Section ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gem.variety ?? "Unknown Gem",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Text(
                              "Date: ${gem.date ?? 'N/A'}",
                              style: TextStyle(color: subTextColor),
                            ),
                          ],
                        ),
                        _buildPriceBadge(gem.targetPrice ?? 0),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- Physical Specs Grid ---
                    Text(
                      "Physical Specifications",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSpecGrid([
                      _specItem(
                        "Final Weight",
                        "${gem.finalWeight} ct",
                        Icons.scale,
                        isDark,
                      ),
                      _specItem(
                        "Color",
                        gem.color ?? "N/A",
                        Icons.palette_outlined,
                        isDark,
                      ),
                      _specItem(
                        "Type",
                        gem.isRough == true ? "Rough" : "Cut",
                        Icons.diamond_outlined,
                        isDark,
                      ),
                      _specItem(
                        "Buy Weight",
                        "${gem.buyingWeight} ct",
                        Icons.shopping_bag_outlined,
                        isDark,
                      ),
                    ]),

                    const SizedBox(height: 24),

                    // --- Investment & Costs Breakdown ---
                    Text(
                      "Investment Breakdown",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black54 : Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _costRow(
                            "Buying Price",
                            gem.buyingPrice ?? 0,
                            subTextColor!,
                            textColor,
                          ),
                          _costRow(
                            "Treatment Cost",
                            gem.treatmentCost ?? 0,
                            subTextColor,
                            textColor,
                          ),
                          _costRow(
                            "Recut Cost",
                            gem.recutCost ?? 0,
                            subTextColor,
                            textColor,
                          ),
                          _costRow(
                            "Transport Cost",
                            gem.transportCost ?? 0,
                            subTextColor,
                            textColor,
                          ),
                          _costRow(
                            "Other Processing",
                            gem.otherProcessingCost ?? 0,
                            subTextColor,
                            textColor,
                          ),
                          const Divider(height: 24),
                          _costRow(
                            "Total Investment",
                            (gem.buyingPrice ?? 0) +
                                (gem.treatmentCost ?? 0) +
                                (gem.recutCost ?? 0) +
                                (gem.transportCost ?? 0) +
                                (gem.otherProcessingCost ?? 0),
                            subTextColor,
                            AppColors.primaryBlue,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),

                    if (gem.otherProcessingDesc != null &&
                        gem.otherProcessingDesc!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        "Processing Notes",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        gem.otherProcessingDesc!,
                        style: TextStyle(color: subTextColor),
                      ),
                    ],

                    const SizedBox(height: 32),

                    // --- Close Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Done",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBadge(double price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Rs. ${price.toStringAsFixed(0)}",
        style: const TextStyle(
          color: AppColors.primaryGreen,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildSpecGrid(List<Widget> items) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.5,
      children: items,
    );
  }

  Widget _specItem(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceAlt : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryBlue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _costRow(
    String label,
    double value,
    Color subColor,
    Color valColor, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: subColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "Rs. ${value.toStringAsFixed(0)}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valColor,
              fontSize: isBold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
