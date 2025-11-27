import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../application/profile_controller.dart';

class FollowingPage extends HookConsumerWidget {
  final String userId;

  const FollowingPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followingState = ref.watch(followingControllerProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('フォロー中'),
      ),
      body: followingState.isLoading && followingState.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : followingState.error != null && followingState.users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(followingState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(
                                  followingControllerProvider(userId).notifier)
                              .loadFollowing(refresh: true);
                        },
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : followingState.users.isEmpty
                  ? const Center(
                      child: Text('まだフォローしていません'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(followingControllerProvider(userId).notifier)
                            .loadFollowing(refresh: true);
                      },
                      child: ListView.builder(
                        itemCount: followingState.users.length +
                            (followingState.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= followingState.users.length) {
                            if (!followingState.isLoading) {
                              Future.microtask(() {
                                ref
                                    .read(followingControllerProvider(userId)
                                        .notifier)
                                    .loadFollowing();
                              });
                            }
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final user = followingState.users[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      user.displayName.isNotEmpty
                                          ? user.displayName[0].toUpperCase()
                                          : '?',
                                    )
                                  : null,
                            ),
                            title: Text(user.displayName),
                            subtitle: Text('@${user.username}'),
                            onTap: () {
                              context.push('/users/${user.id}');
                            },
                          );
                        },
                      ),
                    ),
    );
  }
}
