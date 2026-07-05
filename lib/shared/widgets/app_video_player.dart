import 'dart:io';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:gemhub/core/constants/app_colors.dart';
import 'package:video_player/video_player.dart';

class AppVideoPlayer extends StatefulWidget {
  
  final String videoPath;

  
  final bool autoPlay;

  
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

  
  Future<void> _initializePlayer() async {
    try {
      final String path = widget.videoPath.trim();
      final bool isNetworkUrl =
          path.startsWith('http://') || path.startsWith('https://');

      if (isNetworkUrl) {
        
        _videoPlayerController =
            VideoPlayerController.networkUrl(Uri.parse(path));
      } else {
        
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

      await _videoPlayerController!.initialize();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load player engine: $e';
        _isLoading = false;
      });
    }
  }


  ChewieController _buildChewieController(BuildContext context) {
    return ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: widget.autoPlay,
      looping: widget.looping,
      aspectRatio: _videoPlayerController!.value.aspectRatio,

      
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

      errorBuilder: (context, errorMessage) {
        return ColoredBox(
          color: AppColors.darkBackground,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
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

    _chewieController ??= _buildChewieController(context);

    return AspectRatio(
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}