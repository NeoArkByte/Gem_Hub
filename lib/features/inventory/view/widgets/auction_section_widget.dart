import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/utils/auction_utils.dart';
import 'package:go_router/go_router.dart';

class AuctionSectionWidget extends StatelessWidget {
  final List<GemstoneModel> auctionGems;
  final bool isDark;
  final Color primaryText;
  final Color secondaryText;
  final Color surfaceBg;

  const AuctionSectionWidget({
    super.key,
    required this.auctionGems,
    required this.isDark,
    required this.primaryText,
    required this.secondaryText,
    required this.surfaceBg,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  "Gems on Auction",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                    fontFamily: 'Hanken Grotesk',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${auctionGems.length}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.gavel_rounded,
                      size: 14, color: AppColors.primaryGreen),
                  SizedBox(width: 4),
                  Text(
                    "Weekly reduction",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: auctionGems.length,
            itemBuilder: (context, index) {
              return _buildAuctionGemCard(context, auctionGems[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionGemCard(BuildContext context, GemstoneModel gem) {
    final addedDate = DateTime.tryParse(gem.date) ?? DateTime.now();
    final currentDate = DateTime.now();

    // Calculate elapsed weeks for week display
    final diff = currentDate.difference(addedDate);
    final weeks = diff.inDays ~/ 7;
    final int displayWeeks = weeks < 0 ? 0 : weeks;

    final double auctionPrice = AuctionUtils.calculateAuctionPrice(
      addedDate: addedDate,
      basePrice: gem.targetPrice,
      currentDate: currentDate,
    );

    final double startAuctionPrice = gem.targetPrice * 1.5;
    final double pctChange = gem.targetPrice > 0
        ? ((auctionPrice - gem.targetPrice) / gem.targetPrice) * 100
        : 0.0;

    return GestureDetector(
      onTap: () => context.pushNamed('inventory_details', extra: gem),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: surfaceBg,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? AppColors.darkSurfaceAlt
                : Colors.black.withOpacity(0.04),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Side: Gem Image
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 80,
                height: 80,
                child: _buildCardImage(
                  gem.firstImagePath ?? gem.finalImagePath,
                  isDark,
                  primaryText,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Right Side: Info and Prices
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          gem.variety,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: primaryText,
                            fontFamily: 'Hanken Grotesk',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "Wk $displayWeeks",
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "${gem.color} • ${gem.finalWeight} CT",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Auction Prices
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Start: Rs. ${startAuctionPrice.toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 9,
                                decoration: TextDecoration.lineThrough,
                                color: secondaryText.withOpacity(0.7),
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                  Text(
                                    "Rs. ${auctionPrice.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primaryGreen,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    pctChange >= 0
                                        ? "+${pctChange.toStringAsFixed(0)}%"
                                        : "${pctChange.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: pctChange >= 0
                                          ? AppColors.primaryGreen
                                          : AppColors.dangerRed,
                                    ),
                                  ),
                              ],
                            ),
                          ],
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
}
