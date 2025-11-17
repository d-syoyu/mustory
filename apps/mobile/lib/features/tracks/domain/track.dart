import 'package:freezed_annotation/freezed_annotation.dart';

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
    @Default(false) bool isLiked,
    Map<String, dynamic>? story,
  }) = _Track;

  const Track._();

  bool get hasStory => story != null;

  factory Track.fromJson(Map<String, dynamic> json) => Track(
        id: json['id'] as String,
        title: json['title'] as String,
        artistName: json['artist_name'] as String,
        userId: json['user_id'] as String,
        artworkUrl: json['artwork_url'] as String,
        hlsUrl: json['hls_url'] as String,
        likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
        viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
        isLiked: json['is_liked'] as bool? ?? false,
        story: json['story'] as Map<String, dynamic>?,
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
        'story': story,
      };
}
