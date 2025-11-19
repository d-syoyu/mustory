import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール'),
      ),
      body: profileState.isLoading && profileState.profile == null
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null && profileState.profile == null
              ? Center(
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
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primaryContainer,
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
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              profileState.profile?.displayName ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileState.profile?.email ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Follow Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(profileControllerProvider(userId)
                                          .notifier)
                                      .toggleFollow();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      profileState.profile?.isFollowedByMe ??
                                              false
                                          ? Colors.white
                                          : Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                  foregroundColor:
                                      profileState.profile?.isFollowedByMe ??
                                              false
                                          ? Theme.of(context).colorScheme.primary
                                          : Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                ),
                                child: Text(
                                  profileState.profile?.isFollowedByMe ?? false
                                      ? 'フォロー中'
                                      : 'フォロー',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Stats Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              context,
                              'トラック',
                              profileState.profile?.trackCount ?? 0,
                              null,
                            ),
                            _buildStatItem(
                              context,
                              '物語',
                              profileState.profile?.storyCount ?? 0,
                              null,
                            ),
                            _buildStatItem(
                              context,
                              'フォロワー',
                              profileState.profile?.followerCount ?? 0,
                              () => context.push('/users/$userId/followers'),
                            ),
                            _buildStatItem(
                              context,
                              'フォロー中',
                              profileState.profile?.followingCount ?? 0,
                              () => context.push('/users/$userId/following'),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),

                      // Tabs Section
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
                              height: 400,
                              child: TabBarView(
                                children: [
                                  // Tracks Tab
                                  Center(
                                    child: Text(
                                      'トラック一覧（実装予定）',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  // Stories Tab
                                  Center(
                                    child: Text(
                                      '物語一覧（実装予定）',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  // Likes Tab
                                  Center(
                                    child: Text(
                                      'いいね一覧（実装予定）',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
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
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
