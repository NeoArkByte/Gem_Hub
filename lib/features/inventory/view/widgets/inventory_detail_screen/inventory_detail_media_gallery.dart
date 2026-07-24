import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';

/// Media gallery view displaying main media preview (Image/Video player) and horizontal thumbnail bar.
class InventoryDetailMediaGallery extends StatelessWidget {
  final GemstoneModel gemstone;
  final String currentSelectedPath;
  final bool isShowingVideo;
  final ChewieController? chewieController;
  final Color bgColor;
  final Color borderColor;
  final ValueChanged<String> onPhotoSelected;
  final ValueChanged<String> onVideoSelected;

  const InventoryDetailMediaGallery({
    super.key,
    required this.gemstone,
    required this.currentSelectedPath,
    required this.isShowingVideo,
    required this.chewieController,
    required this.bgColor,
    required this.borderColor,
    required this.onPhotoSelected,
    required this.onVideoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Media Frame
        AspectRatio(
          aspectRatio: 4 / 5,
          child: isShowingVideo
              ? (chewieController != null &&
                      chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Chewie(controller: chewieController!)
                  : const Center(child: CircularProgressIndicator()))
              : (currentSelectedPath.isNotEmpty
                  ? Image.file(
                      File(currentSelectedPath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    )),
        ),

        // Bottom Thumbnail Picker Strip
        Container(
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final photo in gemstone.firstLookPhotos) ...[
                  _buildThumbnail(
                    photo,
                    isActive: currentSelectedPath == photo,
                    onTap: () => onPhotoSelected(photo),
                  ),
                  const SizedBox(width: 12),
                ],
                for (final photo in gemstone.finalPhotos) ...[
                  _buildThumbnail(
                    photo,
                    isActive: currentSelectedPath == photo,
                    onTap: () => onPhotoSelected(photo),
                  ),
                  const SizedBox(width: 12),
                ],
                if (gemstone.firstVideoPath != null) ...[
                  const SizedBox(width: 12),
                  _buildThumbnail(
                    gemstone.firstVideoPath!,
                    isActive: currentSelectedPath == gemstone.firstVideoPath,
                    isVideo: true,
                    onTap: () => onVideoSelected(gemstone.firstVideoPath!),
                  ),
                ],
                if (gemstone.finalVideoPath != null) ...[
                  const SizedBox(width: 12),
                  _buildThumbnail(
                    gemstone.finalVideoPath!,
                    isActive: currentSelectedPath == gemstone.finalVideoPath,
                    isVideo: true,
                    onTap: () => onVideoSelected(gemstone.finalVideoPath!),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(
    String path, {
    bool isActive = false,
    bool isVideo = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : borderColor,
            width: isActive ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? Container(color: Colors.black)
                  : Image.file(
                      File(path),
                      fit: BoxFit.cover,
                    ),
              if (!isActive)
                Container(
                  color: Colors.black26,
                ),
              if (isVideo)
                const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
