import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:gemhub/data/models/inventory/gemstone_model.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:intl/intl.dart';

class GemDetailsScreen extends StatefulWidget {
  final GemstoneModel gemstone;
  const GemDetailsScreen({super.key, required this.gemstone});

  @override
  State<GemDetailsScreen> createState() => _GemDetailsScreenState();
}

class _GemDetailsScreenState extends State<GemDetailsScreen> {
  late String _currentSelectedPath;
  late bool _isShowingVideo;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    // Default to the first available media
    _currentSelectedPath = widget.gemstone.finalImagePath ??
        widget.gemstone.firstImagePath ??
        widget.gemstone.finalVideoPath ??
        widget.gemstone.firstVideoPath ??
        '';
    _isShowingVideo = _currentSelectedPath == widget.gemstone.finalVideoPath ||
        _currentSelectedPath == widget.gemstone.firstVideoPath;

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
            _buildMediaGallery(context),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildPhysicalSpecs(context),
                  const SizedBox(height: 32),
                  _buildInvestmentDetails(context),
                  if (widget.gemstone.otherProcessingDesc.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    _buildNotesSection(context),
                  ],
                  const SizedBox(height: 40),
                  _buildActionButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.gemstone.variety,
                style: TextStyle(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Hanken Grotesk',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inventory ID: #${widget.gemstone.id ?? "N/A"}',
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today,
                  color: AppColors.primaryGreen, size: 14),
              const SizedBox(width: 8),
              Text(
                widget.gemstone.date,
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGallery(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor =
        isDark ? AppColors.darkBackgroundAlt : AppColors.lightBackgroundSoft;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 4 / 5,
          child: _isShowingVideo
              ? (_chewieController != null &&
                      _chewieController!
                          .videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const Center(child: CircularProgressIndicator()))
              : (_currentSelectedPath.isNotEmpty
                  ? Image.file(
                      File(_currentSelectedPath),
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    )),
        ),
        Container(
          width: double.infinity,
          color: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (widget.gemstone.firstImagePath != null)
                  _buildThumbnail(
                    context,
                    widget.gemstone.firstImagePath!,
                    isActive:
                        _currentSelectedPath == widget.gemstone.firstImagePath,
                    onTap: () {
                      setState(() {
                        _currentSelectedPath = widget.gemstone.firstImagePath!;
                        _isShowingVideo = false;
                        _disposeVideoController();
                      });
                    },
                  ),
                if (widget.gemstone.finalImagePath != null) ...[
                  const SizedBox(width: 12),
                  _buildThumbnail(
                    context,
                    widget.gemstone.finalImagePath!,
                    isActive:
                        _currentSelectedPath == widget.gemstone.finalImagePath,
                    onTap: () {
                      setState(() {
                        _currentSelectedPath = widget.gemstone.finalImagePath!;
                        _isShowingVideo = false;
                        _disposeVideoController();
                      });
                    },
                  ),
                ],
                if (widget.gemstone.firstVideoPath != null) ...[
                  const SizedBox(width: 12),
                  _buildThumbnail(
                    context,
                    widget.gemstone.firstVideoPath!,
                    isActive:
                        _currentSelectedPath == widget.gemstone.firstVideoPath,
                    isVideo: true,
                    onTap: () {
                      setState(() {
                        _currentSelectedPath = widget.gemstone.firstVideoPath!;
                        _isShowingVideo = true;
                        _initVideoPlayer(_currentSelectedPath);
                      });
                    },
                  ),
                ],
                if (widget.gemstone.finalVideoPath != null) ...[
                  const SizedBox(width: 12),
                  _buildThumbnail(
                    context,
                    widget.gemstone.finalVideoPath!,
                    isActive:
                        _currentSelectedPath == widget.gemstone.finalVideoPath,
                    isVideo: true,
                    onTap: () {
                      setState(() {
                        _currentSelectedPath = widget.gemstone.finalVideoPath!;
                        _isShowingVideo = true;
                        _initVideoPlayer(_currentSelectedPath);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, String path,
      {bool isActive = false, bool isVideo = false, VoidCallback? onTap}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

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
                  ? Container(color: Colors.black) // Placeholder for video
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

  Widget _buildPhysicalSpecs(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Physical Specs',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Hanken Grotesk',
              ),
            ),
            Icon(Icons.info_outline, color: subtitleColor, size: 20),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
          children: [
            _buildSpecCard(
              context,
              Icons.scale,
              'WEIGHT (Final)',
              '${widget.gemstone.finalWeight} ct',
              AppColors.primaryBlue,
            ),
            _buildSpecCard(
              context,
              Icons.palette,
              'COLOR',
              widget.gemstone.color,
              AppColors.primaryGreen,
            ),
            _buildSpecCard(
              context,
              Icons.diamond,
              'TYPE',
              widget.gemstone.isRough ? 'Rough' : 'Cut',
              AppColors.accentGreen,
            ),
            _buildSpecCard(
              context,
              Icons.shopping_bag,
              'BUY WEIGHT',
              '${widget.gemstone.buyingWeight} ct',
              AppColors.darkSurfaceAlt,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecCard(BuildContext context, IconData icon, String label,
      String value, Color accentColor) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color labelColor =
        isDark ? AppColors.greyTextMutedLight : AppColors.greyText;
    final Color borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.black.withOpacity(0.08);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(isDark ? 0.4 : 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInvestmentDetails(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    final gemstone = widget.gemstone;
    final totalInvested = gemstone.buyingPrice +
        gemstone.treatmentCost +
        gemstone.recutCost +
        gemstone.transportCost +
        gemstone.otherProcessingCost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investment Details',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor.withOpacity(isDark ? 0.4 : 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInvestmentRow(context, 'Buying Price',
                        _formatCurrency(gemstone.buyingPrice),
                        isBold: true),
                    const SizedBox(height: 16),
                    _buildInvestmentRow(context, 'Treatment',
                        _formatCurrency(gemstone.treatmentCost),
                        isMuted: gemstone.treatmentCost == 0),
                    const SizedBox(height: 16),
                    _buildInvestmentRow(
                        context,
                        'Recut/Processing',
                        _formatCurrency(
                            gemstone.recutCost + gemstone.otherProcessingCost),
                        isMuted: (gemstone.recutCost +
                                gemstone.otherProcessingCost) ==
                            0),
                    const SizedBox(height: 16),
                    _buildInvestmentRow(context, 'Transport',
                        _formatCurrency(gemstone.transportCost),
                        isMuted: gemstone.transportCost == 0),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color:
                      AppColors.primaryGreen.withOpacity(isDark ? 0.05 : 0.08),
                  border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2)),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Invested',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatCurrency(totalInvested),
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInvestmentRow(BuildContext context, String label, String value,
      {bool isBold = false, bool isMuted = false}) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;

    final opacity = isMuted ? 0.6 : 1.0;
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : AppColors.textDarkAlt;
    final Color subtitleColor =
        isDark ? AppColors.greyTextLight : AppColors.greyText;
    final Color cardColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color borderColor =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Processing Notes',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Hanken Grotesk',
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor.withOpacity(isDark ? 0.4 : 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
          ),
          child: Text(
            widget.gemstone.otherProcessingDesc,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
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
