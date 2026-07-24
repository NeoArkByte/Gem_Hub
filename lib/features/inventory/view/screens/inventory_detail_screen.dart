import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:gemhub/features/inventory/view/widgets/inventory_detail_screen/inventory_detail_screen_widgets.dart';

class InventoryDetailScreen extends StatefulWidget {
  final GemstoneModel gemstone;
  const InventoryDetailScreen({super.key, required this.gemstone});

  @override
  State<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends State<InventoryDetailScreen> {
  late String _currentSelectedPath;
  late bool _isShowingVideo;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();

    _currentSelectedPath = widget.gemstone.finalPhotos.isNotEmpty
        ? widget.gemstone.finalPhotos.first
        : widget.gemstone.firstLookPhotos.isNotEmpty
            ? widget.gemstone.firstLookPhotos.first
            : widget.gemstone.finalVideo ??
                widget.gemstone.firstLookVideo ??
                '';

    _isShowingVideo = _currentSelectedPath == widget.gemstone.finalVideo ||
        _currentSelectedPath == widget.gemstone.firstLookVideo;

    if (_isShowingVideo && _currentSelectedPath.isNotEmpty) {
      _initVideoPlayer(_currentSelectedPath);
    }
  }

  void _initVideoPlayer(String path) async {
    _disposeVideoController();
    _videoPlayerController = VideoPlayerController.file(File(path));
    await _videoPlayerController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryGreen,
        handleColor: AppColors.primaryGreen,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.withOpacity(0.5),
      ),
    );
    setState(() {});
  }

  void _disposeVideoController() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _chewieController = null;
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeVideoController();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(
      symbol: 'Rs. ',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(amount);
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'N/A';
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      final cleaned = dateString.split(' ').first;
      try {
        return DateFormat('dd MMM yyyy').format(DateTime.parse(cleaned));
      } catch (_) {
        return cleaned;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color appBarBg = isDark
        ? AppColors.darkBackground.withOpacity(0.8)
        : Colors.white.withOpacity(0.8);
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Gem Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(widget.gemstone.targetPrice),
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'VALUATION',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 9,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InventoryDetailMediaGallery(
              gemstone: widget.gemstone,
              currentSelectedPath: _currentSelectedPath,
              isShowingVideo: _isShowingVideo,
              chewieController: _chewieController,
              bgColor: bgColor,
              borderColor: borderColor,
              onPhotoSelected: (photo) {
                setState(() {
                  _currentSelectedPath = photo;
                  _isShowingVideo = false;
                  _disposeVideoController();
                });
              },
              onVideoSelected: (videoPath) {
                setState(() {
                  _currentSelectedPath = videoPath;
                  _isShowingVideo = true;
                  _initVideoPlayer(_currentSelectedPath);
                });
              },
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InventoryDetailHeader(
                    gemstone: widget.gemstone,
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    formattedDate: _formatDate(widget.gemstone.date),
                  ),
                  const SizedBox(height: 24),
                  InventoryDetailPhysicalSpecs(gemstone: widget.gemstone),
                  const SizedBox(height: 32),
                  InventoryDetailInvestmentCard(
                    gemstone: widget.gemstone,
                    formatCurrency: _formatCurrency,
                  ),
                  if (widget.gemstone.otherProcessingDesc.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    InventoryDetailNotesCard(
                      notes: widget.gemstone.otherProcessingDesc,
                    ),
                  ],
                  const SizedBox(height: 40),
                  _buildBackButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: AppColors.primaryGreen.withOpacity(0.25),
        ),
        onPressed: () => Navigator.pop(context),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Back to Inventory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.arrow_back, size: 20),
          ],
        ),
      ),
    );
  }
}
