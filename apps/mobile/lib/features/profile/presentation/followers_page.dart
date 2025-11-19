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
                              .read(followersControllerProvider(userId).notifier)
                              .loadFollowers(refresh: true);
                        },
                        child: const Text('再読み込み'),
                      ),
                    ],
                  ),
                )
              : followersState.users.isEmpty
                  ? const Center(
                      child: Text('フォロワーがいません'),
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
                            // Load more indicator
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
                              child: Text(
                                user.displayName.substring(0, 1).toUpperCase(),
                              ),
                            ),
                            title: Text(user.displayName),
                            subtitle:
                                user.email != null ? Text(user.email!) : null,
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
