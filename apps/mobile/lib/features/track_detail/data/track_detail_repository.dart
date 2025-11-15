import 'dart:async';

import '../../../core/models/track.dart';

class TrackDetailRepository {
  Future<Track> fetchTrack(String trackId) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    const story = Story(
      id: 'story-1',
      trackId: 'demo-track',
      lead: '月光の下で出会った物語。',
      body:
          'このトラックは静かな夜の散歩をイメージして作られています。コード進行に沿って短編を添える予定です。',
      isLiked: false,
      likeCount: 12,
    );

    return Track(
      id: trackId,
      title: 'Synthetic Lullaby',
      artistName: 'Codex',
      artworkUrl: 'https://placehold.co/600x600/png',
      hlsUrl: 'https://example.com/audio/demo-track/playlist.m3u8',
      isLiked: false,
      likeCount: 42,
      story: story,
    );
  }

  Future<List<Comment>> fetchTrackComments(String trackId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return [
      Comment(
        id: 'track-comment-1',
        authorDisplayName: 'Listener 01',
        body: 'このリズム最高です！',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        targetType: CommentTargetType.track,
      ),
    ];
  }

  Future<List<Comment>> fetchStoryComments(String storyId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return [
      Comment(
        id: 'story-comment-1',
        authorDisplayName: 'Story Lover',
        body: '続きが気になります。',
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        targetType: CommentTargetType.story,
      ),
    ];
  }

  Future<void> postComment({
    required CommentTargetType targetType,
    required String targetId,
    required String body,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // API integration pending.
  }
}
