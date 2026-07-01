import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class CustomConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final IconData? icon;

  const CustomConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel = 'Delete',
    this.cancelLabel = 'Cancel',
    this.confirmColor = AppColors.dangerRed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          28,
        ), // Matches premium summary card curve
        side: BorderSide(
          color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorderAlt,
          width: 1.5,
        ),
      ),
      elevation: 24,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 340,
        ), // Keeps it structured on tablets
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Dynamic Decorated Icon Header
            if (icon != null) ...[
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      confirmColor.withOpacity(0.18),
                      confirmColor.withOpacity(0.06),
                    ],
                  ),
                ),
                child: Center(child: Icon(icon, color: confirmColor, size: 32)),
              ),
              const SizedBox(height: 20),
            ],

            // Optimized Title Block
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textDarkAlt,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),

            // Fluid Body Text Block
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                content,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : AppColors.greyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5, // Better text readability line spacing
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Action Row Overhaul
            Row(
              children: [
                // Enhanced Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      splashFactory: InkSparkle
                          .splashFactory, // High-fidelity Android 12+ ripple
                      side: BorderSide(
                        color: isDark
                            ? AppColors.darkSurfaceAlt
                            : AppColors.lightBorder,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : AppColors.textDark,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Enhanced Action/Confirm Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      splashFactory: InkSparkle.splashFactory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
