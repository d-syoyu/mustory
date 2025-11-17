import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Search screen inspired by premium streaming apps.
class SearchPage extends HookConsumerWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF05050A), Color(0xFF0F1222)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'アーティスト / トラック / タグを検索',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // TODO: hook actual search
                  },
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  children: [
                    Text(
                      'ムードから探す',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _MoodGrid(),
                    const SizedBox(height: 32),
                    Text(
                      '最近の検索',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _RecentSearches(),
                    const SizedBox(height: 32),
                    Text(
                      'トレンドのタグ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    _TrendingChipList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodGrid extends StatelessWidget {
  final List<_MoodCardData> moods = const [
    _MoodCardData('City Night', Icons.nightlife, [Color(0xFF7F00FF), Color(0xFFE100FF)]),
    _MoodCardData('Chillhop', Icons.coffee, [Color(0xFF00C6FF), Color(0xFF0072FF)]),
    _MoodCardData('Epic Story', Icons.auto_stories, [Color(0xFFFF512F), Color(0xFFDD2476)]),
    _MoodCardData('Morning Glow', Icons.wb_twilight, [Color(0xFFFFF200), Color(0xFFFFA400)]),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: moods.length,
      itemBuilder: (context, index) {
        final mood = moods[index];
        return InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: mood.colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(mood.icon, color: Colors.white),
                const Spacer(),
                Text(
                  mood.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodCardData {
  final String label;
  final IconData icon;
  final List<Color> colors;

  const _MoodCardData(this.label, this.icon, this.colors);
}

class _RecentSearches extends StatelessWidget {
  final List<String> queries = const [
    '夜風に溶けるローファイ',
    'CityPop 80s',
    'アンビエント ストーリー',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: queries
          .map(
            (q) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history, color: Colors.white70),
              title: Text(q),
              trailing: const Icon(Icons.north_east),
              onTap: () {},
            ),
          )
          .toList(),
    );
  }
}

class _TrendingChipList extends StatelessWidget {
  final List<String> tags = const [
    '#Afterhours',
    '#MidnightDrive',
    '#LoFiBeats',
    '#NeoCity',
    '#PianoStories',
    '#FutureSoul',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (tag) => Chip(
              label: Text(tag),
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          )
          .toList(),
    );
  }
}
