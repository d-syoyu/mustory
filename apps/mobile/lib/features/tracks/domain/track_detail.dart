import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';
import 'comment.dart';

part 'track_detail.freezed.dart';

@Freezed(toJson: false, fromJson: false)
class TrackDetail with _$TrackDetail {
  const factory TrackDetail({
    required Track track,
    required List<Comment> trackComments,
    required List<Comment> storyComments,
  }) = _TrackDetail;

  factory TrackDetail.fromJson(Map<String, dynamic> json) {
    return TrackDetail(
      track: Track.fromJson(json['track'] as Map<String, dynamic>),
      trackComments: (json['track_comments'] as List<dynamic>)
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
      storyComments: (json['story_comments'] as List<dynamic>)
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
