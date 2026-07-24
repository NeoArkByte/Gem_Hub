import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/features/inventory/view/screens/inventory_add_entry_screen.dart';
import 'package:gemhub/features/jobs/view/screens/post_new_job.dart';

class QuickActionsSection extends StatelessWidget {
  final bool isDark;

  const QuickActionsSection({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            Icons.add_circle,
            "Add Gem",
            "Inventory Input",
            AppColors.blueSoft,
            AppColors.accentBlue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InventoryAddEntryScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _actionButton(
            Icons.business_center,
            "Post Job",
            "Hire Talent",
            AppColors.mintLight,
            AppColors.darkGreen,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    IconData icon,
    String title,
    String sub,
    Color bg,
    Color iconCol,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: iconCol,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: iconCol,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            Text(
              sub,
              style: TextStyle(color: iconCol.withOpacity(0.6), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
