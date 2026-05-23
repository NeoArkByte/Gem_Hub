import 'dart:io';
import 'package:flutter/material.dart';
import 'package:job_market/core/constants/app_colors.dart';

class GemFilePickerTile extends StatelessWidget {
  final String label;
  final File? file;
  final String? remoteUrl;
  final VoidCallback onTap;

  const GemFilePickerTile({
    super.key,
    required this.label,
    this.file,
    this.remoteUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color fieldBg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    String fileName = "Selected";
    if (file != null) {
      fileName = file!.path.split(Platform.pathSeparator).last;
    } else if (remoteUrl != null && remoteUrl!.isNotEmpty) {
      fileName = remoteUrl!.split('/').last;
      if (fileName.contains('?')) {
        fileName = fileName.split('?').first;
      }
    }

    bool hasFile = file != null || (remoteUrl != null && remoteUrl!.isNotEmpty);

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
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkSurfaceAlt : AppColors.lightBorder,
              ),
            ),
            child: hasFile
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          color: AppColors.dangerRed,
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.lightBackground : AppColors.textDark,
                            ),
                          ),
                        ),
                        if (file == null && remoteUrl != null)
                          const Text(
                            "(Remote)",
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.greyText,
                            ),
                          ),
                      ],
                    ),
                  )
                : const Center(
                    child: Icon(
                      Icons.upload_file,
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
