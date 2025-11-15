import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mustory_mobile/features/home/presentation/home_page.dart';
import 'package:mustory_mobile/features/track_detail/presentation/track_detail_page.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'tracks/:trackId',
            name: 'track-detail',
            builder: (context, state) {
              final trackId = state.pathParameters['trackId']!;
              return TrackDetailPage(trackId: trackId);
            },
          ),
        ],
      ),
    ],
  ),
);
