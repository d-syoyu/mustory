import 'package:flutter/material.dart';

import '../../../../core/models/track.dart' show Comment, Story;

class StoryTabView extends StatelessWidget {
  const StoryTabView({
    super.key,
    required this.story,
    required this.comments,
    required this.commentController,
    required this.isLoggedIn,
    required this.isOwner,
    required this.onSubmitComment,
    this.onCreateStory,
  });

  final Story? story;
  final List<Comment> comments;
  final TextEditingController commentController;
  final bool isLoggedIn;
  final bool isOwner;
  final Future<void> Function(String body) onSubmitComment;
  final VoidCallback? onCreateStory;

  @override
  Widget build(BuildContext context) {
    if (story == null) {
      return _StoryEmptyState(
        isOwner: isOwner,
        onCreateStory: onCreateStory,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          story!.lead,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Text(
          story!.body,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        CommentsSection(
          title: '物語へのコメント',
          comments: comments,
        ),
        const SizedBox(height: 12),
        if (isLoggedIn)
          CommentInput(
            controller: commentController,
            hintText: '感想を残す...',
            onSubmit: () => onSubmitComment(commentController.text),
          )
        else
          const LoginCta(),
      ],
    );
  }
}

class _StoryEmptyState extends StatelessWidget {
  const _StoryEmptyState({
    required this.isOwner,
    required this.onCreateStory,
  });

  final bool isOwner;
  final VoidCallback? onCreateStory;

  @override
  Widget build(BuildContext context) {
    if (!isOwner) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('まだ物語はありません。'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('物語を作成してリスナーに世界観を届けましょう。'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onCreateStory,
              child: const Text('物語を作成する'),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentsSection extends StatelessWidget {
  const CommentsSection({
    required this.title,
    required this.comments,
  });

  final String title;
  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (comments.isEmpty)
          const Text('最初のコメントを投稿しましょう。')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final comment = comments[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(comment.authorDisplayName),
                subtitle: Text(comment.body),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: comments.length,
          ),
      ],
    );
  }
}

class CommentInput extends StatelessWidget {
  const CommentInput({
    required this.controller,
    required this.hintText,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hintText;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          minLines: 2,
          maxLines: 4,
          decoration: InputDecoration(hintText: hintText),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () async {
              await onSubmit();
            },
            child: const Text('投稿'),
          ),
        ),
      ],
    );
  }
}

class LoginCta extends StatelessWidget {
  const LoginCta();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('コメントするにはログインしてください。'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('ログイン'),
            ),
          ],
        ),
      ),
    );
  }
}
