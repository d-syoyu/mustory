import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';
import 'package:mustory_mobile/core/audio/audio_player_controller.dart';
import 'package:mustory_mobile/core/ui/app_palettes.dart';
import 'package:mustory_mobile/features/tracks/domain/comment.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';

import '../application/track_detail_controller.dart';

class TrackDetailPage extends HookConsumerWidget {
  const TrackDetailPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trackDetailControllerProvider(trackId));
    final audioState = ref.watch(audioPlayerStateProvider);
    final storyCommentController = useTextEditingController();
    final trackCommentController = useTextEditingController();
    final sendingStory = useState(false);
    final sendingTrackComment = useState(false);

    if (state.isLoading && state.trackDetail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.error != null && state.trackDetail == null) {
      return _DetailErrorView(
        message: state.error!,
        onRetry: () => ref.read(trackDetailControllerProvider(trackId).notifier).refresh(),
      );
    }

    final detail = state.trackDetail!;
    final track = detail.track;
    final isCurrentTrack = audioState.currentTrack?.id == track.id;
    final isPlaying = isCurrentTrack && audioState.isPlaying;
    final isLoadingAudio = isCurrentTrack && audioState.isLoading;
    final storyMap = track.story;
    final storyId = storyMap?['id'] as String?;
    final isOwner = ref.watch(currentUserIdProvider) == track.userId;

    Future<void> submitStoryComment() async {
      final text = storyCommentController.text.trim();
      if (text.isEmpty || storyId == null) return;
      sendingStory.value = true;
      try {
        await ref
            .read(trackDetailControllerProvider(trackId).notifier)
            .addStoryComment(storyId, text);
        storyCommentController.clear();
      } finally {
        sendingStory.value = false;
      }
    }

    Future<void> submitTrackComment() async {
      final text = trackCommentController.text.trim();
      if (text.isEmpty) return;
      sendingTrackComment.value = true;
      try {
        await ref
            .read(trackDetailControllerProvider(trackId).notifier)
            .addComment(text);
        trackCommentController.clear();
      } finally {
        sendingTrackComment.value = false;
      }
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Stack(
          children: [
            _ArtworkBackdrop(imageUrl: track.artworkUrl),
            SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, _) => [
                  SliverAppBar(
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    expandedHeight: 420,
                    pinned: true,
                    leading: IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      onPressed: () => context.go('/'),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.share_outlined),
                        onPressed: () {},
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: _TrackHero(
                        track: track,
                        audioState: audioState,
                        isCurrentTrack: isCurrentTrack,
                        isPlaying: isPlaying,
                        isLoadingAudio: isLoadingAudio,
                        onTogglePlay: () async {
                          final controller =
                              ref.read(audioPlayerControllerProvider.notifier);
                          if (isCurrentTrack) {
                            await controller.togglePlayPause();
                          } else {
                            await controller.playTrack(track);
                          }
                        },
                        onToggleLike: () {
                          final notifier =
                              ref.read(trackDetailControllerProvider(trackId).notifier);
                          if (track.isLiked) {
                            notifier.unlikeTrack();
                          } else {
                            notifier.likeTrack();
                          }
                        },
                        sliderOnChanged: (value) {
                          ref
                              .read(audioPlayerControllerProvider.notifier)
                              .seek(Duration(seconds: value.toInt()));
                        },
                        progressValue: isCurrentTrack
                            ? audioState.position.inSeconds.toDouble().clamp(
                                  0,
                                  audioState.duration.inSeconds.toDouble() > 0
                                      ? audioState.duration.inSeconds.toDouble()
                                      : 1,
                                )
                            : 0,
                        maxProgress: audioState.duration.inSeconds > 0
                            ? audioState.duration.inSeconds.toDouble()
                            : 1,
                      ),
                    ),
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(64),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        color: Colors.black.withValues(alpha: 0.3),
                        child: const TabBar(
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicatorWeight: 3,
                          tabs: [
                            Tab(text: '物語'),
                            Tab(text: 'コメント'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                body: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _StoryTab(
                      story: storyMap,
                      isOwner: isOwner,
                      comments: detail.storyComments,
                      controller: storyCommentController,
                      isSending: sendingStory.value,
                      onSubmit: submitStoryComment,
                    ),
                    _TrackCommentsTab(
                      comments: detail.trackComments,
                      controller: trackCommentController,
                      isSending: sendingTrackComment.value,
                      onSubmit: submitTrackComment,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtworkBackdrop extends StatelessWidget {
  const _ArtworkBackdrop({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.55),
          BlendMode.srcOver,
        ),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => Container(color: AppColors.background),
        ),
      ),
    );
  }
}

class _TrackHero extends StatelessWidget {
  const _TrackHero({
    required this.track,
    required this.audioState,
    required this.isCurrentTrack,
    required this.isPlaying,
    required this.isLoadingAudio,
    required this.onTogglePlay,
    required this.onToggleLike,
    required this.sliderOnChanged,
    required this.progressValue,
    required this.maxProgress,
  });

  final Track track;
  final AudioPlayerState audioState;
  final bool isCurrentTrack;
  final bool isPlaying;
  final bool isLoadingAudio;
  final Future<void> Function() onTogglePlay;
  final VoidCallback onToggleLike;
  final void Function(double) sliderOnChanged;
  final double progressValue;
  final double maxProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B0B13), Color(0xFF1C1D2A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: CachedNetworkImage(
                      imageUrl: track.artworkUrl,
                      width: double.infinity,
                      height: 240,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.white12),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.music_note, size: 72),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    track.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artistName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: progressValue,
                      max: maxProgress,
                      onChanged: isCurrentTrack ? sliderOnChanged : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(
                            isCurrentTrack ? audioState.position : Duration.zero,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        Text(
                          _formatDuration(
                            isCurrentTrack ? audioState.duration : Duration.zero,
                          ),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          track.isLiked ? Icons.favorite : Icons.favorite_border,
                          color:
                              track.isLiked ? AppColors.accentSecondary : Colors.white,
                        ),
                        onPressed: onToggleLike,
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: onTogglePlay,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: AppColors.accentSecondary,
                        ),
                        child: isLoadingAudio
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isCurrentTrack && isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 32,
                              ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StoryTab extends StatelessWidget {
  const _StoryTab({
    required this.story,
    required this.isOwner,
    required this.comments,
    required this.controller,
    required this.isSending,
    required this.onSubmit,
  });

  final Map<String, dynamic>? story;
  final bool isOwner;
  final List<Comment> comments;
  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    if (story == null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOwner ? 'まだ物語はありません' : 'このトラックにはまだ物語がありません',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  isOwner
                      ? '感じた風景や背景を綴って、Mustoryらしい没入体験を届けましょう。'
                      : '作者が準備中です。新しいストーリーを待ちましょう。',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go('/profile/upload'),
                    child: const Text('物語を作成する'),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          story!['lead'] as String? ?? '',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          story!['body'] as String? ?? '',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        _CommentsList(title: '物語のコメント', comments: comments),
        const SizedBox(height: 16),
        _CommentComposer(
          controller: controller,
          hintText: '感想をシェア...',
          onSend: onSubmit,
          isSending: isSending,
        ),
      ],
    );
  }
}

class _TrackCommentsTab extends StatelessWidget {
  const _TrackCommentsTab({
    required this.comments,
    required this.controller,
    required this.isSending,
    required this.onSubmit,
  });

  final List<Comment> comments;
  final TextEditingController controller;
  final bool isSending;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _CommentsList(title: 'トラックへのコメント', comments: comments),
        const SizedBox(height: 16),
        _CommentComposer(
          controller: controller,
          hintText: '感じた情景や気持ちを残す...',
          onSend: onSubmit,
          isSending: isSending,
        ),
      ],
    );
  }
}

class _CommentsList extends StatelessWidget {
  const _CommentsList({required this.title, required this.comments});

  final String title;
  final List<Comment> comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title (${comments.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        if (comments.isEmpty)
          Text(
            'まだコメントはありません。',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          )
        else
          ...comments.map((comment) => _CommentTile(comment: comment)),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                child: Text(_initials(comment.authorDisplayName)),
              ),
              const SizedBox(width: 12),
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
                      _timeAgo(comment.createdAt),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(Icons.favorite, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${comment.likeCount}',
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment.body,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.hintText,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final String hintText;
  final Future<void> Function() onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          child: FilledButton.icon(
            onPressed: isSending ? null : onSend,
            icon: isSending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('送信'),
          ),
        ),
      ],
    );
  }
}

class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('再読み込み')),
          ],
        ),
      ),
    );
  }
}

String _formatDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String _timeAgo(DateTime dateTime) {
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

String _initials(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }
  return trimmed.substring(0, 1).toUpperCase();
}
