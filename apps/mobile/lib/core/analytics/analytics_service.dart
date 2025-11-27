import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(),
);

class AnalyticsService {
  Future<void> track(String event, {Map<String, dynamic>? properties}) async {
    if (kDebugMode) {
      debugPrint('Analytics: $event, properties: $properties');
    }
    // TODO: connect PostHog/Sentry.
  }

  Future<void> logAppStarted() async {
    await track('app_started');
  }

  Future<void> logTrackPlayed(String trackId) async {
    await track('track_played', properties: {'track_id': trackId});
  }

  Future<void> logStoryExpanded(String trackId, String storyId) async {
    await track('story_expanded', properties: {
      'track_id': trackId,
      'story_id': storyId,
    });
  }

  Future<void> logCommentPosted({
    required String targetType, // 'track' or 'story'
    required String targetId,
    required String commentId,
  }) async {
    await track('comment_posted', properties: {
      'target_type': targetType,
      'target_id': targetId,
      'comment_id': commentId,
    });
  }

  Future<void> logNotificationOpened(String notificationId) async {
    await track('notification_opened', properties: {
      'notification_id': notificationId,
    });
  }

  Future<void> logTrackUploaded({
    required String trackId,
    required bool hasStory,
  }) async {
    await track('track_uploaded', properties: {
      'track_id': trackId,
      'has_story': hasStory,
    });
  }
}
