class MediaProcessingState {
  final bool isLoading;
  final double progress; // 0.0 to 1.0 (0 to 100 in display)
  final bool isSuccess;
  final String? error;

  MediaProcessingState({
    this.isLoading = false,
    this.progress = 0.0,
    this.isSuccess = false,
    this.error,
  });

  MediaProcessingState copyWith({
    bool? isLoading,
    double? progress,
    bool? isSuccess,
    String? error,
  }) {
    return MediaProcessingState(
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_loading': isLoading,
      'progress': progress,
      'is_success': isSuccess,
      'error': error,
    };
  }

  factory MediaProcessingState.fromMap(Map<String, dynamic> map) {
    return MediaProcessingState(
      isLoading: map['is_loading'] ?? false,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      isSuccess: map['is_success'] ?? false,
      error: map['error'],
    );
  }
}
