import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../application/profile_controller.dart';

class FollowersPage extends HookConsumerWidget {
  final String userId;

  const FollowersPage({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersState = ref.watch(followersControllerProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('フォロワー'),
      ),
      body: followersState.isLoading && followersState.users.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : followersState.error != null && followersState.users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(followersState.error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref
                              .read(
                                  followersControllerProvider(userId).notifier)
                              .loadFollowers(refresh: true);
                        },
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : followersState.users.isEmpty
                  ? const Center(
                      child: Text('フォロワーがまだいません'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(followersControllerProvider(userId).notifier)
                            .loadFollowers(refresh: true);
                      },
                      child: ListView.builder(
                        itemCount: followersState.users.length +
                            (followersState.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= followersState.users.length) {
                            if (!followersState.isLoading) {
                              Future.microtask(() {
                                ref
                                    .read(followersControllerProvider(userId)
                                        .notifier)
                                    .loadFollowers();
                              });
                            }
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          final user = followersState.users[index];
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
