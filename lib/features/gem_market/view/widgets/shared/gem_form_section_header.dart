import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class GemFormSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const GemFormSectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryYellow, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryYellow,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
