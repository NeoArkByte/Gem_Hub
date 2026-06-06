import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  /// The video source path. Can be a local absolute file path or a remote network URL.
  final String videoPath;

  /// Whether the video should start playing automatically when loaded.
  final bool autoPlay;

  /// Whether the video should loop continuously when it reaches the end.
  final bool looping;

  const AppVideoPlayer({
    super.key,
    required this.videoPath,
    this.autoPlay = false,
    this.looping = false,
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  /// Handles auto-detection of the path type and configures the native video engines.
  /// Note: ChewieController (which needs Theme/context) is built in build(), not here.
  Future<void> _initializePlayer() async {
    try {
      final String path = widget.videoPath.trim();
      final bool isNetworkUrl =
          path.startsWith('http://') || path.startsWith('https://');

      if (isNetworkUrl) {
        // 1A. Initialize from a remote network stream
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(path));
      } else {
        // 1B. Initialize from a local file, checking existence first
        final file = File(path);
        if (!await file.exists()) {
          if (!mounted) return;
          setState(() {
            _errorMessage =
                'The requested video file could not be found locally.';
            _isLoading = false;
          });
          return;
        }
        _videoPlayerController = VideoPlayerController.file(file);
      }

      // 2. Initialize the lower-level video controller
      await _videoPlayerController!.initialize();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        // ChewieController is intentionally created in build() where
        // Theme.of(context) is safe to call.
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load player engine: $e';
        _isLoading = false;
      });
    }
  }

  /// Builds the ChewieController once the video is ready.
  /// Called from build() so Theme.of(context) is always safe.
  ChewieController _buildChewieController(BuildContext context) {
    return ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      aspectRatio: _videoPlayerController!.value.aspectRatio,

      // FIX: Theme.of(context) is safe here — we're inside build()
      // Using AppColors for consistent branding
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryGreen,
        handleColor: AppColors.accentGreen,
        backgroundColor: AppColors.darkSurfaceAlt,
        bufferedColor: AppColors.darkGreen,
      ),

      placeholder: const ColoredBox(
        color: AppColors.darkBackground,
        child: Center(
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      ),

      // FIX: style moved from Padding to Text; Padding has no style param
      errorBuilder: (context, errorMessage) {
        return ColoredBox(
          color: AppColors.darkBackground,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                // FIX: style is on Text, not Padding
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.accentRed,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // Completely dismantle controllers to prevent audio leaks or background processing
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator.adaptive(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.accentRed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    // FIX: ChewieController created here in build() — Theme.of(context) is safe.
    // Only create once; reuse on subsequent rebuilds.
    _chewieController ??= _buildChewieController(context);

    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}