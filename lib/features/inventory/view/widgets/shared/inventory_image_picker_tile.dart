import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';

class InventoryImagePickerTile extends StatelessWidget {
  final String label;
  final File? image;
  final String? remoteUrl;
  final VoidCallback onTap;

  const InventoryImagePickerTile({
    super.key,
    required this.label,
    this.image,
    this.remoteUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.grey[300] : const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                : remoteUrl != null && remoteUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          remoteUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.primaryYellow,
                          size: 30,
                        ),
                      ),
          ),
        ),
      ],
    );
  }
}
