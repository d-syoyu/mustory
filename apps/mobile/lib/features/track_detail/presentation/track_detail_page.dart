import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/models/track.dart';
import '../application/track_detail_controller.dart';
import 'widgets/comment_tab.dart';
import 'widgets/story_tab.dart';

class TrackDetailPage extends HookConsumerWidget {
  const TrackDetailPage({super.key, required this.trackId});

  final String trackId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = useState(TrackDetailTab.story);
    final trackCommentController = useTextEditingController();
    final storyCommentController = useTextEditingController();
    final state = ref.watch(trackDetailControllerProvider(trackId));

    const isLoggedIn = true; // TODO: wire authStateProvider
    const isOwner = true; // TODO: compare against current user

    return Scaffold(
      appBar: AppBar(
        title: const Text('トラック詳細'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
            tooltip: 'シェア',
          ),
        ],
      ),
      body: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _ErrorView(
            message: '$err',
            onRetry: () =>
                ref.read(trackDetailControllerProvider(trackId).notifier).refresh(),
          ),
          data: (detail) {
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(trackDetailControllerProvider(trackId).notifier)
                  .refresh(),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  _TrackHero(track: detail.track),
                  const SizedBox(height: 24),
                  SegmentedButton<TrackDetailTab>(
                    segments: const [
                      ButtonSegment(
                        value: TrackDetailTab.story,
                        label: Text('物語'),
                      ),
                      ButtonSegment(
                        value: TrackDetailTab.comments,
                        label: Text('コメント'),
                      ),
                    ],
                    showSelectedIcon: false,
                    selected: <TrackDetailTab>{tab.value},
                    onSelectionChanged: (selection) {
                      tab.value = selection.first;
                    },
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: tab.value == TrackDetailTab.story
                        ? StoryTabView(
                            key: const ValueKey('story-tab'),
                            story: detail.track.story,
                            comments: detail.storyComments,
                            commentController: storyCommentController,
                            isLoggedIn: isLoggedIn,
                            isOwner: isOwner,
                            onSubmitComment: (body) async {
                              await ref
                                  .read(
                                    trackDetailControllerProvider(trackId).notifier,
                                  )
                                  .postComment(
                                    targetType: CommentTargetType.story,
                                    body: body,
                                  );
                              storyCommentController.clear();
                            },
                            onCreateStory: () {},
                          )
                        : TrackCommentsTabView(
                            key: const ValueKey('comments-tab'),
                            comments: detail.trackComments,
                            isLoggedIn: isLoggedIn,
                            commentController: trackCommentController,
                            onSubmit: (body) async {
                              await ref
                                  .read(
                                    trackDetailControllerProvider(trackId).notifier,
                                  )
                                  .postComment(
                                    targetType: CommentTargetType.track,
                                    body: body,
                                  );
                              trackCommentController.clear();
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TrackHero extends StatelessWidget {
  const _TrackHero({required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: AspectRatio(
            aspectRatio: 1,
            child: Image.network(
              track.artworkUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) =>
                  const ColoredBox(color: Colors.black12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          track.title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          track.artistName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.play_arrow),
              label: const Text('再生'),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {},
              icon: Icon(
                track.isLiked ? Icons.favorite : Icons.favorite_border,
              ),
            ),
            Text('${track.likeCount}'),
          ],
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onRetry,
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }
}

enum TrackDetailTab { story, comments }
