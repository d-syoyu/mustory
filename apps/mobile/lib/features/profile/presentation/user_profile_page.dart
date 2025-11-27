import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/auth/auth_controller.dart';
import '../application/profile_controller.dart';

class UserProfilePage extends HookConsumerWidget {
  final String userId;

  const UserProfilePage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider(userId));
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final profile = profileState.profile;
    final currentUserId = authState.maybeWhen(
      authenticated: (uid, _, __, ___) => uid,
      orElse: () => null,
    );
    final isSelf = profile != null && currentUserId == profile.id;

    if (profileState.isLoading && profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileState.error != null && profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('プロフィール')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profileState.error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(profileControllerProvider(userId).notifier)
                      .loadProfile();
                },
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(profileControllerProvider(userId).notifier)
              .loadProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage: profile?.avatarUrl != null
                          ? NetworkImage(profile!.avatarUrl!)
                          : null,
                      child: profile?.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      profile?.displayName ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (profile != null)
                      Text(
                        '@${profile.username}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    const SizedBox(height: 6),
                    Text(
                      profile?.email ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        profile.bio!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                    if (!isSelf && profile != null) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ref
                                .read(
                                    profileControllerProvider(userId).notifier)
                                .toggleFollow();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: profile.isFollowedByMe
                                ? Colors.white
                                : theme.colorScheme.secondary,
                            foregroundColor: profile.isFollowedByMe
                                ? theme.colorScheme.primary
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(profile.isFollowedByMe
                              ? Icons.favorite
                              : Icons.favorite_border),
                          label:
                              Text(profile.isFollowedByMe ? 'フォロー中' : 'フォローする'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatChip(
                              label: 'フォロワー',
                              value: profile?.followerCount ?? 0,
                              onTap: () => context.push('/users/$userId/followers'),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            _StatChip(
                              label: 'フォロー中',
                              value: profile?.followingCount ?? 0,
                              onTap: () => context.push('/users/$userId/following'),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            _StatChip(
                              label: 'トラック',
                              value: profile?.trackCount ?? 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (profile?.linkUrl != null &&
                        profile!.linkUrl!.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (profile.location != null &&
                              profile.location!.isNotEmpty)
                            Chip(
                              avatar: const Icon(Icons.location_on, size: 16),
                              label: Text(profile.location!),
                            ),
                          ActionChip(
                            label: Text(profile.linkUrl!),
                            onPressed:
                                () {}, // No browser launch in CLI summary; kept as placeholder.
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const Divider(),

              // Placeholder tabs
              DefaultTabController(
                length: 3,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'トラック'),
                        Tab(text: '物語'),
                        Tab(text: 'いいね'),
                      ],
                    ),
                    SizedBox(
                      height: 320,
                      child: TabBarView(
                        children: [
                          _buildPlaceholderTab(
                            context,
                            title: 'トラック一覧',
                            description: 'このユーザーのトラックは後続の実装で表示します。',
                            icon: Icons.library_music,
                          ),
                          _buildPlaceholderTab(
                            context,
                            title: '物語一覧',
                            description: '物語フィードは今後追加予定です。',
                            icon: Icons.menu_book_rounded,
                          ),
                          _buildPlaceholderTab(
                            context,
                            title: 'いいね一覧',
                            description: 'いいねしたトラックは今後表示予定です。',
                            icon: Icons.favorite,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderTab(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback? onTap;

  const _StatChip({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    final chip = Chip(
      label: Text('$label: $value'),
    );
    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: chip,
      ),
    );
  }
}
