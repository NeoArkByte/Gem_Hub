import 'package:flutter/material.dart';
import 'package:job_market/core/constants/app_colors.dart';

class GemBottomActionBar extends StatelessWidget {
  final bool isFavourite;
  final VoidCallback onFavouriteToggle;

  const GemBottomActionBar({
    super.key,
    required this.isFavourite,
    required this.onFavouriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onFavouriteToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isFavourite
                    ? AppColors.redPale
                    : (isDark
                          ? AppColors.darkSurfaceAlt
                          : AppColors.lightBackgroundGrey),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFavourite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isFavourite
                    ? AppColors.dangerRed
                    : (isDark ? AppColors.greyTextLight : AppColors.greyText),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.accentGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size.fromHeight(50),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text(
                  'Contact Seller',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
