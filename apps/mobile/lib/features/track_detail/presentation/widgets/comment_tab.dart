import 'package:flutter/material.dart';

import '../../../../core/models/track.dart' show Comment;
import 'story_tab.dart' show CommentInput, CommentsSection, LoginCta;

class TrackCommentsTabView extends StatelessWidget {
  const TrackCommentsTabView({
    super.key,
    required this.comments,
    required this.isLoggedIn,
    required this.commentController,
    required this.onSubmit,
  });

  final List<Comment> comments;
  final bool isLoggedIn;
  final TextEditingController commentController;
  final Future<void> Function(String body) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentsSection(title: 'トラックへのコメント', comments: comments),
        const SizedBox(height: 12),
        if (isLoggedIn)
          CommentInput(
            controller: commentController,
            hintText: 'トラックの感想を投稿...',
            onSubmit: () => onSubmit(commentController.text),
          )
        else
          const LoginCta(),
      ],
    );
  }
}
