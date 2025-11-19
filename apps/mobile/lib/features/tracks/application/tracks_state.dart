import 'package:mustory_mobile/features/tracks/domain/track.dart';

class TracksState {
  final List<Track> tracks;
  final bool isLoading;
  final String? error;
  final bool hasMore;

  TracksState({
    this.tracks = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
  });

  TracksState copyWith({
    List<Track>? tracks,
    bool? isLoading,
    String? error,
    bool? hasMore,
    bool clearError = false,
  }) {
    return TracksState(
      tracks: tracks ?? this.tracks,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
