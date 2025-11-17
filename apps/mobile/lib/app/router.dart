import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mustory_mobile/features/home/presentation/home_page.dart';
import 'package:mustory_mobile/features/profile/presentation/my_page.dart';
import 'package:mustory_mobile/features/tracks/presentation/track_detail_page.dart';
import 'package:mustory_mobile/features/auth/presentation/login_page.dart';
import 'package:mustory_mobile/features/auth/presentation/signup_page.dart';
import 'package:mustory_mobile/features/upload/presentation/track_upload_page.dart';
import 'package:mustory_mobile/features/search/presentation/search_page.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';
import 'package:mustory_mobile/app/main_shell.dart';

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
        // Track detail page (outside shell to hide bottom nav)
        GoRoute(
          path: '/tracks/:trackId',
          name: 'track-detail',
          builder: (context, state) {
            final trackId = state.pathParameters['trackId']!;
            return TrackDetailPage(trackId: trackId);
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            // Home Tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  name: 'home',
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            // Search Tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  name: 'search',
                  builder: (context, state) => const SearchPage(),
                ),
              ],
            ),
            // My Page Tab
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  name: 'profile',
                  builder: (context, state) => const MyPage(),
                  routes: [
                    GoRoute(
                      path: 'upload',
                      name: 'upload',
                      builder: (context, state) => const TrackUploadPage(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  },
);
