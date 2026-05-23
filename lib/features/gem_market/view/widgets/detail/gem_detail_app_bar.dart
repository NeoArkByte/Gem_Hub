import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gemhub/data/models/gem_market/gem_model.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class GemDetailAppBar extends StatelessWidget {
  final Gem gem;
  final List<String> images;
  final int currentImage;
  final ValueChanged<int> onPageChanged;

  const GemDetailAppBar({
    super.key,
    required this.gem,
    required this.images,
    required this.currentImage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      elevation: 0,
      foregroundColor: isDark ? Colors.white : AppColors.darkBackground,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _circleBtn(
          Icons.arrow_back_ios_new_rounded,
          isDark ? Colors.white : AppColors.darkBackground,
          () => Navigator.of(context).pop(),
          isDark,
        ),
      ),
      title: null,
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              itemCount: images.length,
              onPageChanged: onPageChanged,
              itemBuilder: (_, i) => Image.network(
                images[i],
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.accentGreenLight,
                  child: const Center(
                    child: Icon(
                      Icons.diamond,
                      size: 72,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ),
            // Subtle Bottom Gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
              ),
            ),
            // Category Glass Badge
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Text(
                      gem.variety?.toUpperCase() ?? 'GEM',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: currentImage == i ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: currentImage == i ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleBtn(
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }
}
