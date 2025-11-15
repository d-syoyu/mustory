import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mustory'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Demo tracks',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          _DemoTrackTile(
            title: 'Synthetic Lullaby',
            artist: 'Codex',
            description: 'Tap to preview the track detail scaffold.',
            onTap: () => context.go('/tracks/demo-track'),
          ),
        ],
      ),
    );
  }
}

class _DemoTrackTile extends StatelessWidget {
  const _DemoTrackTile({
    required this.title,
    required this.artist,
    required this.description,
    required this.onTap,
  });

  final String title;
  final String artist;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        onTap: onTap,
        title: Text(title),
        subtitle: Text('$artist · $description'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
