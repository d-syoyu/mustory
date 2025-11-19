import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/search_controller.dart';
import '../../tracks/presentation/widgets/track_card.dart';

/// Search screen - search for tracks, artists, and tags
class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchState = ref.watch(searchControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '検索',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 26,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '曲名、アーティスト、タグで検索',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          searchController.clear();
                          ref.read(searchControllerProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                if (value.trim().isNotEmpty) {
                  ref.read(searchControllerProvider.notifier).search(value);
                } else {
                  ref.read(searchControllerProvider.notifier).clear();
                }
              },
            ),
          ),

          // Search results / suggestions
          Expanded(
            child: _buildContent(context, ref, searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    SearchState searchState,
  ) {
    // Show loading indicator
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show error message
    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              searchState.error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show search results
    if (searchState.query.isNotEmpty) {
      if (searchState.results.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '検索結果が見つかりませんでした',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '"${searchState.query}" に一致するトラックはありません',
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: searchState.results.length,
        itemBuilder: (context, index) {
          final track = searchState.results[index];
          return TrackCard(
            track: track,
            onTap: () {
              context.push('/track/${track.id}');
            },
            onLike: () {
              // TODO: Implement like functionality
            },
          );
        },
      );
    }

    final theme = Theme.of(context);

    // Show empty state with suggestions
    return CustomScrollView(
      slivers: [
        // Trending tags section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    size: 22,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'トレンドタグ',
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                ),
              ],
            ),
          ),
        ),

        // Trending tags chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                '#LoFi',
                '#アンビエント',
                '#弾き語り',
                '#インスト',
                '#Jazz',
                '#エレクトロニカ',
              ]
                  .map((tag) => ActionChip(
                        avatar: Icon(
                          Icons.tag_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          tag,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                        side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onPressed: () {
                          ref
                              .read(searchControllerProvider.notifier)
                              .search(tag);
                        },
                      ))
                  .toList(),
            ),
          ),
        ),

        // Search tips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 36, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        size: 22,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '検索のヒント',
                      style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSearchTip(
                  context,
                  Icons.music_note_rounded,
                  '曲名で検索',
                  '例: "夜空"',
                  theme,
                ),
                const SizedBox(height: 4),
                _buildSearchTip(
                  context,
                  Icons.person_rounded,
                  'アーティスト名で検索',
                  '例: "山田太郎"',
                  theme,
                ),
                const SizedBox(height: 4),
                _buildSearchTip(
                  context,
                  Icons.tag_rounded,
                  'タグで検索',
                  '例: "#LoFi"',
                  theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchTip(
    BuildContext context,
    IconData icon,
    String title,
    String example,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  example,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
