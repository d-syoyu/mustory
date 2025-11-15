class Track {
  const Track({
    required this.id,
    required this.title,
    required this.artistName,
    required this.artworkUrl,
    required this.hlsUrl,
    required this.isLiked,
    required this.likeCount,
    required this.story,
  });

  final String id;
  final String title;
  final String artistName;
  final String artworkUrl;
  final String hlsUrl;
  final bool isLiked;
  final int likeCount;
  final Story? story;
}

class Story {
  const Story({
    required this.id,
    required this.trackId,
    required this.lead,
    required this.body,
    required this.isLiked,
    required this.likeCount,
  });

  final String id;
  final String trackId;
  final String lead;
  final String body;
  final bool isLiked;
  final int likeCount;
}

class Comment {
  const Comment({
    required this.id,
    required this.authorDisplayName,
    required this.body,
    required this.createdAt,
    required this.targetType,
  });

  final String id;
  final String authorDisplayName;
  final String body;
  final DateTime createdAt;
  final CommentTargetType targetType;
}

enum CommentTargetType { track, story }
