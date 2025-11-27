import 'package:freezed_annotation/freezed_annotation.dart';
import '../../profile/domain/user_profile.dart';

part 'track.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String artistName,
    required String userId,
    required String artworkUrl,
    required String hlsUrl,
    @Default(0) int likeCount,
    @Default(0) int viewCount,
    @Default(0) int trackCommentCount,
    @Default(0) int storyCommentCount,
    @Default(false) bool isLiked,
    Map<String, dynamic>? story,
    UserSummary? user,
    DateTime? createdAt,
    // Audio features
    int? durationSeconds,
    double? bpm,
    double? loudnessLufs,
    double? moodValence,
    double? moodEnergy,
    bool? hasVocals,
    @Default(<String>[]) List<String> tags,
  }) = _Track;

  const Track._();

  bool get hasStory => story != null;

  int get totalCommentCount => trackCommentCount + storyCommentCount;

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        artistName: json['artist_name'] as String? ?? '',
        userId: json['user_id'] as String? ?? '',
        artworkUrl: json['artwork_url'] as String? ?? '',
        hlsUrl: json['hls_url'] as String? ?? '',
        likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
        viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
        trackCommentCount:
            (json['track_comment_count'] as num?)?.toInt() ?? 0,
        storyCommentCount:
            (json['story_comment_count'] as num?)?.toInt() ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        story: json['story'] as Map<String, dynamic>?,
        user: json['user'] != null
            ? UserSummary.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        // Audio features
        durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
        bpm: (json['bpm'] as num?)?.toDouble(),
        loudnessLufs: (json['loudness_lufs'] as num?)?.toDouble(),
        moodValence: (json['mood_valence'] as num?)?.toDouble(),
        moodEnergy: (json['mood_energy'] as num?)?.toDouble(),
        hasVocals: json['has_vocals'] as bool?,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist_name': artistName,
        'user_id': userId,
        'artwork_url': artworkUrl,
        'hls_url': hlsUrl,
        'like_count': likeCount,
        'view_count': viewCount,
        'is_liked': isLiked,
        'track_comment_count': trackCommentCount,
        'story_comment_count': storyCommentCount,
        'story': story,
        'user': user?.toJson(),
        'created_at': createdAt?.toIso8601String(),
        'duration_seconds': durationSeconds,
        'bpm': bpm,
        'loudness_lufs': loudnessLufs,
        'mood_valence': moodValence,
        'mood_energy': moodEnergy,
        'has_vocals': hasVocals,
        'tags': tags,
      };
}
