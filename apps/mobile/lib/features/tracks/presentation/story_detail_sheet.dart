import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../domain/comment.dart';
import '../application/track_detail_controller.dart';

class StoryDetailSheet extends HookConsumerWidget {
  final String trackId;
  final Map<String, dynamic> story;
  final List<Comment> storyComments;

  const StoryDetailSheet({
    super.key,
    required this.trackId,
    required this.story,
    required this.storyComments,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final isSending = useState(false);
    final replyingTo = useState<Comment?>(null);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.book, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'ストーリー',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Story content
                    Text(
                      story['lead'] as String? ?? '',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      story['body'] as String? ?? '',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    // Story metadata
                    Row(
                      children: [
                        Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${story['like_count'] ?? 0}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${storyComments.length}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Comments section
                    Text(
                      'コメント (${storyComments.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),

                    if (storyComments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.comment_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'まだコメントがありません',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...storyComments
                          .where((c) => c.parentCommentId == null)
                          .map((comment) => _buildCommentItem(
                                context,
                                ref,
                                comment,
                                storyComments,
                                replyingTo,
                              )),
                  ],
                ),
              ),

              // Comment input
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(color: Colors.grey[800]!),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Show reply indicator if replying to someone
                    if (replyingTo.value != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.reply, size: 16, color: Colors.grey[400]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${replyingTo.value!.authorDisplayName}に返信中',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => replyingTo.value = null,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: textController,
                            decoration: InputDecoration(
                              hintText: replyingTo.value != null
                                  ? '返信を入力...'
                                  : 'ストーリーにコメント...',
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            maxLines: null,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) async {
                              if (value.trim().isEmpty || isSending.value) return;
                              isSending.value = true;
                              await ref.read(trackDetailControllerProvider(trackId).notifier).addStoryComment(
                                    story['id'] as String,
                                    value.trim(),
                                    parentCommentId: replyingTo.value?.id,
                                  );
                              textController.clear();
                              replyingTo.value = null;
                              isSending.value = false;
                              if (context.mounted) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: isSending.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          onPressed: isSending.value
                              ? null
                              : () async {
                                  final text = textController.text.trim();
                                  if (text.isEmpty) return;
                                  isSending.value = true;
                                  await ref.read(trackDetailControllerProvider(trackId).notifier).addStoryComment(
                                        story['id'] as String,
                                        text,
                                        parentCommentId: replyingTo.value?.id,
                                      );
                                  textController.clear();
                                  replyingTo.value = null;
                                  isSending.value = false;
                                  if (context.mounted) {
                                    FocusScope.of(context).unfocus();
                                  }
                                },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCommentItem(
    BuildContext context,
    WidgetRef ref,
    Comment comment,
    List<Comment> allComments,
    ValueNotifier<Comment?> replyingTo, {
    bool isReply = false,
  }) {
    // Get replies for this comment
    final replies = allComments
        .where((c) => c.parentCommentId == comment.id)
        .toList();

    return Container(
      padding: EdgeInsets.only(
        left: isReply ? 48 : 0,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(
                  comment.authorDisplayName.isNotEmpty
                      ? comment.authorDisplayName[0].toUpperCase()
                      : '?',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorDisplayName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      _formatDateTime(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${comment.likeCount}',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          // Reply button
          Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  replyingTo.value = comment;
                },
                icon: Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                label: Text(
                  '返信',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (comment.replyCount > 0) ...[
                const SizedBox(width: 16),
                Text(
                  '${comment.replyCount}件の返信',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ],
          ),
          // Show replies
          if (replies.isNotEmpty)
            ...replies.map((reply) => _buildCommentItem(
                  context,
                  ref,
                  reply,
                  allComments,
                  replyingTo,
                  isReply: true,
                )),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.year}/${dateTime.month}/${dateTime.day}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }
}
