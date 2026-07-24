import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:gemhub/features/inventory/view/screens/inventory_update_entry_screen.dart';
import 'package:gemhub/shared/widgets/custom_confirm_dialog.dart';

/// Interactive Luxury Gemstone Card displaying image preview, status badge, details, and action menu.
class InventoryGemCard extends ConsumerWidget {
  final GemstoneModel gem;
  final Color cardBg;
  final Color textColor;
  final Color subTextColor;
  final bool isDark;

  const InventoryGemCard({
    super.key,
    required this.gem,
    required this.cardBg,
    required this.textColor,
    required this.subTextColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _buildCardMenu(context, ref),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _buildStatusBadge(isSold ? "SOLD" : "AVAILABLE"),
                    ),
                  ],
                ),
              ),

              // Bottom: Info Section
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

  Widget _buildCardImage(String? imagePath) {
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
      child: Icon(
        Icons.diamond_outlined,
        size: 40,
        color: textColor.withOpacity(0.15),
      ),
    );
  }

  Widget _buildCardMenu(BuildContext context, WidgetRef ref) {
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
                    InventoryUpdateEntryScreen(gemstoneToEdit: gem),
              ),
            );
          } else if (value == 'delete') {
            _confirmDelete(context, ref);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primaryGreen),
                SizedBox(width: 10),
                Text(
                  "Edit Details",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.dangerRed),
                SizedBox(width: 10),
                Text(
                  "Remove",
                  style: TextStyle(
                    color: AppColors.dangerRed,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
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
