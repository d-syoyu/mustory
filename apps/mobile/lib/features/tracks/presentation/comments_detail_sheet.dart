import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../application/track_detail_controller.dart';
import '../domain/comment.dart';

class CommentsDetailSheet extends HookConsumerWidget {
  const CommentsDetailSheet({
    super.key,
    required this.trackId,
    required this.trackComments,
  });

  final String trackId;
  final List<Comment> trackComments;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final inputFocusNode = useFocusNode();
    final isSending = useState(false);
    final replyingTo = useState<Comment?>(null);
    final likedOverrides = useState<Map<String, bool>>(<String, bool>{});
    final expandedThreads = useState<Set<String>>(<String>{});
    final authState = ref.watch(authControllerProvider);
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_, __, ___, ____) => true,
      orElse: () => false,
    );

    final topLevelCommentCount = trackComments
        .where((comment) => comment.parentCommentId == null)
        .length;

    useEffect(() {
      expandedThreads.value = trackComments
          .where((comment) => comment.parentCommentId == null)
          .map((c) => c.id)
          .toSet();
      likedOverrides.value = <String, bool>{};
      return null;
    }, [trackComments]);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        if (!isAuthenticated) {
          return _LockedCommentView(
            onLogin: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
          );
        }

        final topLevelComments = trackComments
            .where((comment) => comment.parentCommentId == null)
            .toList();
        final highlightedComment = _pickHighlightedComment(topLevelComments);

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const _SheetHandle(),
              _CommentsHeader(
                count: topLevelCommentCount,
                onClose: () => Navigator.pop(context),
              ),
              const Divider(height: 1),
              Expanded(
                child: topLevelComments.isEmpty
                    ? _EmptyState(
                        onStart: () {
                          replyingTo.value = null;
                          inputFocusNode.requestFocus();
                        },
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.only(
                          left: 8,
                          right: 8,
                          bottom: 32,
                        ),
                        itemCount: topLevelComments.length +
                            (highlightedComment != null ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (highlightedComment != null && index == 0) {
                            return _HighlightCard(
                              comment: highlightedComment,
                              onJump: () {
                                final position = topLevelComments.indexWhere(
                                    (c) => c.id == highlightedComment.id);
                                if (position > 0) {
                                  scrollController.animateTo(
                                    (position) * 140,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              },
                            );
                          }

                          final offset = highlightedComment != null ? 1 : 0;
                          final comment = topLevelComments[index - offset];

                          return _buildCommentItem(
                            context,
                            ref,
                            comment,
                            trackComments,
                            replyingTo,
                            likedOverrides,
                            expandedThreads,
                          );
                        },
                      ),
              ),
              _CommentComposer(
                focusNode: inputFocusNode,
                controller: textController,
                isSending: isSending,
                replyingTo: replyingTo,
                onSubmit: (text) async {
                  final controller =
                      ref.read(trackDetailControllerProvider(trackId).notifier);
                  await controller.addComment(
                    text,
                    parentCommentId: replyingTo.value?.id,
                  );
                },
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
    ValueNotifier<Comment?> replyingTo,
    ValueNotifier<Map<String, bool>> likedOverrides,
    ValueNotifier<Set<String>> expandedThreads, {
    bool isReply = false,
  }) {
    final replies =
        allComments.where((c) => c.parentCommentId == comment.id).toList();
    final override = likedOverrides.value[comment.id];
    final effectiveLiked = override ?? comment.isLiked;
    final likeDelta = override == null
        ? 0
        : override && !comment.isLiked
            ? 1
            : (!override && comment.isLiked)
                ? -1
                : 0;
    final displayedLikeCount = comment.likeCount + likeDelta;
    final isExpanded =
        isReply ? true : expandedThreads.value.contains(comment.id);

    return Container(
      padding: EdgeInsets.only(
        left: isReply ? 48 : 16,
        right: 16,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      effectiveLiked ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: effectiveLiked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey[600],
                    ),
                    onPressed: () async {
                      final newOverrides =
                          Map<String, bool>.from(likedOverrides.value);
                      final nextValue = !effectiveLiked;
                      if (nextValue == comment.isLiked) {
                        newOverrides.remove(comment.id);
                      } else {
                        newOverrides[comment.id] = nextValue;
                      }
                      likedOverrides.value = newOverrides;

                      try {
                        await ref
                            .read(
                              trackDetailControllerProvider(trackId).notifier,
                            )
                            .setCommentLike(
                              commentId: comment.id,
                              isStoryComment: comment.targetType == 'story',
                              like: nextValue,
                            );
                      } catch (_) {
                        final reverted =
                            Map<String, bool>.from(likedOverrides.value);
                        if (comment.isLiked == nextValue) {
                          reverted.remove(comment.id);
                        } else {
                          reverted[comment.id] = comment.isLiked;
                        }
                        likedOverrides.value = reverted;
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('いいね操作に失敗しました'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$displayedLikeCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      replyingTo.value = comment;
                    },
                    icon: Icon(Icons.reply, size: 16, color: Colors.grey[600]),
                    label: const Text('返信'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (!isReply && replies.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        final updated = Set<String>.from(expandedThreads.value);
                        if (isExpanded) {
                          updated.remove(comment.id);
                        } else {
                          updated.add(comment.id);
                        }
                        expandedThreads.value = updated;
                      },
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      label: Text(
                        isExpanded ? '返信を隠す' : '返信を表示 (${replies.length})',
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              PopupMenuButton<String>(
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'report',
                    child: Text('報告する'),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'report') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('報告を受け付けました'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          if (isExpanded)
            ...replies.map(
              (reply) => _buildCommentItem(
                context,
                ref,
                reply,
                allComments,
                replyingTo,
                likedOverrides,
                expandedThreads,
                isReply: true,
              ),
            ),
        ],
      ),
    );
  }

  Comment? _pickHighlightedComment(List<Comment> comments) {
    if (comments.isEmpty) return null;
    Comment best = comments.first;
    var bestScore = _commentScore(best);

    for (final candidate in comments.skip(1)) {
      final score = _commentScore(candidate);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }

    return bestScore == 0 ? null : best;
  }

  int _commentScore(Comment comment) =>
      (comment.likeCount * 2) + comment.replyCount;

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

class _CommentsHeader extends StatelessWidget {
  const _CommentsHeader({
    required this.count,
    required this.onClose,
  });

  final int count;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.comment, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'トラックコメント（$count）',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  const _HighlightCard({
    required this.comment,
    required this.onJump,
  });

  final Comment comment;
  final VoidCallback onJump;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    '注目のコメント',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${comment.likeCount}件のいいね / ${comment.replyCount}件の返信',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onJump,
                  child: const Text('スレッドへ移動'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 54,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '最初の声を届けましょう',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'このトラックの感想やエピソードを共有して、最初のトークを始めませんか？',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onStart,
              child: const Text('今すぐコメントを書く'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedCommentView extends StatelessWidget {
  const _LockedCommentView({required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 12),
            const Text('ログインしてコメントに参加しましょう'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onLogin,
              child: const Text('ログインする'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.focusNode,
    required this.controller,
    required this.isSending,
    required this.replyingTo,
    required this.onSubmit,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueNotifier<bool> isSending;
  final ValueNotifier<Comment?> replyingTo;
  final Future<void> Function(String) onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            16 +
            MediaQuery.of(context).padding.bottom / 2,
        left: 16,
        right: 16,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (replyingTo.value != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${replyingTo.value!.authorDisplayName}に返信中',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
          if (replyingTo.value != null) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  focusNode: focusNode,
                  controller: controller,
                  decoration: InputDecoration(
                    hintText:
                        replyingTo.value != null ? '返信を入力...' : 'トラックにコメント...',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) async {
                    if (value.trim().isEmpty || isSending.value) return;
                    isSending.value = true;
                    await onSubmit(value.trim());
                    controller.clear();
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
                        final text = controller.text.trim();
                        if (text.isEmpty) return;
                        isSending.value = true;
                        await onSubmit(text);
                        controller.clear();
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
    );
  }
}
