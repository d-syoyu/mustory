import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/search_controller.dart';
import '../../tracks/presentation/widgets/compact_track_tile.dart';
import '../../../core/widgets/skeleton_loader.dart';

/// Search screen - search for tracks, artists, and users
class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchTextController = useTextEditingController();
    final focusNode = useFocusNode();
    final searchState = ref.watch(searchControllerProvider);
    final theme = Theme.of(context);

    // Sync text controller with search query when tapping history
    useEffect(() {
      if (searchState.query.isNotEmpty &&
          searchTextController.text != searchState.query) {
        searchTextController.text = searchState.query;
        searchTextController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchTextController.text.length),
        );
      }
      return null;
    }, [searchState.query]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: searchTextController,
                focusNode: focusNode,
                autofocus: false,
                decoration: InputDecoration(
                  hintText: '曲名、アーティスト、ユーザーで検索',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  suffixIcon: searchTextController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                          onPressed: () {
                            searchTextController.clear();
                            ref.read(searchControllerProvider.notifier).clear();
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (value) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .searchWithDebounce(value);
                },
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    ref.read(searchControllerProvider.notifier).search(value);
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),

            // Content
            Expanded(
              child: searchState.query.isNotEmpty
                  ? _buildSearchResults(context, ref, searchState)
                  : _buildBrowseContent(context, ref, searchState),
            ),
          ],
        ),
      ),
    );
  }

  /// Build search results view
  Widget _buildSearchResults(
    BuildContext context,
    WidgetRef ref,
    SearchState searchState,
  ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Filter tabs and sort
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Filter tabs
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'すべて',
                        isSelected:
                            searchState.filterType == SearchFilterType.all,
                        onTap: () => ref
                            .read(searchControllerProvider.notifier)
                            .setFilterType(SearchFilterType.all),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'トラック',
                        isSelected:
                            searchState.filterType == SearchFilterType.tracks,
                        onTap: () => ref
                            .read(searchControllerProvider.notifier)
                            .setFilterType(SearchFilterType.tracks),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'ユーザー',
                        isSelected:
                            searchState.filterType == SearchFilterType.users,
                        onTap: () => ref
                            .read(searchControllerProvider.notifier)
                            .setFilterType(SearchFilterType.users),
                      ),
                    ],
                  ),
                ),
              ),
              // Sort button
              PopupMenuButton<SearchSortOption>(
                icon: Icon(
                  Icons.sort_rounded,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                onSelected: (option) {
                  ref
                      .read(searchControllerProvider.notifier)
                      .setSortOption(option);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: SearchSortOption.relevance,
                    child: Row(
                      children: [
                        if (searchState.sortOption == SearchSortOption.relevance)
                          Icon(Icons.check,
                              size: 18, color: theme.colorScheme.primary),
                        if (searchState.sortOption == SearchSortOption.relevance)
                          const SizedBox(width: 8),
                        const Text('関連度順'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SearchSortOption.newest,
                    child: Row(
                      children: [
                        if (searchState.sortOption == SearchSortOption.newest)
                          Icon(Icons.check,
                              size: 18, color: theme.colorScheme.primary),
                        if (searchState.sortOption == SearchSortOption.newest)
                          const SizedBox(width: 8),
                        const Text('新着順'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: SearchSortOption.popular,
                    child: Row(
                      children: [
                        if (searchState.sortOption == SearchSortOption.popular)
                          Icon(Icons.check,
                              size: 18, color: theme.colorScheme.primary),
                        if (searchState.sortOption == SearchSortOption.popular)
                          const SizedBox(width: 8),
                        const Text('人気順'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Result count
        if (!searchState.isLoading && searchState.totalResultCount > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${searchState.totalResultCount}件の結果',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),

        // Results list
        Expanded(
          child: _buildResultsList(context, ref, searchState),
        ),
      ],
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    WidgetRef ref,
    SearchState searchState,
  ) {
    final theme = Theme.of(context);

    // Loading state
    if (searchState.isLoading) {
      return const _SearchResultsSkeleton();
    }

    // Error state
    if (searchState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: theme.colorScheme.error.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              'エラーが発生しました',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              searchState.error!,
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final tracks = searchState.filteredTrackResults;
    final users = searchState.filteredUserResults;

    // Empty state
    if (tracks.isEmpty && users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              '検索結果が見つかりませんでした',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '"${searchState.query}" に一致する結果はありません',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Results
    return ListView(
      children: [
        // User results
        if (users.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'ユーザー',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ...users.map((user) => _UserTile(user: user)),
          if (tracks.isNotEmpty) const Divider(height: 24),
        ],

        // Track results
        if (tracks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              'トラック',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          ...tracks.asMap().entries.map((entry) => CompactTrackTile(
                track: entry.value,
                onTap: () {
                  context.push('/tracks/${entry.value.id}', extra: entry.value);
                },
              )),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  /// Build browse content (when not searching)
  Widget _buildBrowseContent(
    BuildContext context,
    WidgetRef ref,
    SearchState searchState,
  ) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        // Search history chips
        if (searchState.searchHistory.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  '最近の検索',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(searchControllerProvider.notifier).clearHistory();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'クリア',
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: searchState.searchHistory.map((query) {
                return InputChip(
                  label: Text(query),
                  labelStyle: theme.textTheme.bodySmall,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onDeleted: () {
                    ref
                        .read(searchControllerProvider.notifier)
                        .removeFromHistory(query);
                  },
                  onPressed: () {
                    ref.read(searchControllerProvider.notifier).search(query);
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Category grid
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.explore_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ジャンル・ムードで探す',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _CategoryCard(
                label: 'Lo-Fi',
                color: Colors.purple,
                icon: Icons.nightlight_round,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('LoFi'),
              ),
              _CategoryCard(
                label: 'Jazz',
                color: Colors.amber.shade700,
                icon: Icons.piano,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('Jazz'),
              ),
              _CategoryCard(
                label: 'アンビエント',
                color: Colors.teal,
                icon: Icons.spa,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('アンビエント'),
              ),
              _CategoryCard(
                label: 'エレクトロニカ',
                color: Colors.cyan,
                icon: Icons.electric_bolt,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('エレクトロニカ'),
              ),
              _CategoryCard(
                label: '弾き語り',
                color: Colors.orange,
                icon: Icons.mic,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('弾き語り'),
              ),
              _CategoryCard(
                label: 'インスト',
                color: Colors.indigo,
                icon: Icons.music_note,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('インスト'),
              ),
              _CategoryCard(
                label: '作業用BGM',
                color: Colors.green,
                icon: Icons.headphones,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('作業用'),
              ),
              _CategoryCard(
                label: 'チル',
                color: Colors.pink,
                icon: Icons.favorite,
                onTap: () => ref
                    .read(searchControllerProvider.notifier)
                    .search('チル'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Trending tracks
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  size: 18,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '人気のトラック',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (searchState.isTrendingLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                CompactTrackTileSkeleton(),
                CompactTrackTileSkeleton(),
                CompactTrackTileSkeleton(),
              ],
            ),
          )
        else if (searchState.trendingTracks.isNotEmpty)
          ...searchState.trendingTracks.asMap().entries.map((entry) {
            final track = entry.value;
            return CompactTrackTile(
              track: track,
              index: entry.key + 1,
              onTap: () {
                context.push('/tracks/${track.id}', extra: track);
              },
            );
          })
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'トラックがありません',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),

        const SizedBox(height: 32),
      ],
    );
  }
}

/// Filter chip widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Category card widget
class _CategoryCard extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// User tile widget
class _UserTile extends StatelessWidget {
  final dynamic user;

  const _UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: user.avatarUrl == null
            ? Icon(
                Icons.person,
                color: theme.colorScheme.primary,
              )
            : null,
      ),
      title: Text(
        user.displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '@${user.username}',
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: () {
        context.push('/users/${user.id}');
      },
    );
  }
}

/// Skeleton for search results
class _SearchResultsSkeleton extends StatelessWidget {
  const _SearchResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 8),
        CompactTrackTileSkeleton(),
        CompactTrackTileSkeleton(),
        CompactTrackTileSkeleton(),
        CompactTrackTileSkeleton(),
        CompactTrackTileSkeleton(),
      ],
    );
  }
}
