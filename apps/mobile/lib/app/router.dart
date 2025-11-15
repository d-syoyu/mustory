import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mustory_mobile/features/home/presentation/home_page.dart';
import 'package:mustory_mobile/features/tracks/presentation/track_detail_page.dart';
import 'package:mustory_mobile/features/auth/presentation/login_page.dart';
import 'package:mustory_mobile/features/auth/presentation/signup_page.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoginRoute = state.matchedLocation == '/login';
        final isSignupRoute = state.matchedLocation == '/signup';

        // If not authenticated and not on auth routes, redirect to login
        if (!isAuthenticated && !isLoginRoute && !isSignupRoute) {
          return '/login';
        }

        // If authenticated and on login route, redirect to home
        if (isAuthenticated && isLoginRoute) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupPage(),
        ),
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
    );
  },
);
