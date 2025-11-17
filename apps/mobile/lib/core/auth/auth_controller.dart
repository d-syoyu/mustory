import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'auth_repository.dart';
import 'auth_state.dart';

class AuthController extends StateNotifier<AppAuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthController(this._authRepository) : super(const AppAuthState.initial()) {
    _checkAuthState();
    _listenToAuthChanges();
  }

  void _checkAuthState() {
    final user = _authRepository.currentUser;
    final session = _authRepository.currentSession;

    if (user != null && session != null) {
      state = AppAuthState.authenticated(
        userId: user.id,
        email: user.email ?? '',
        displayName: user.userMetadata?['display_name'] ?? '',
        accessToken: session.accessToken,
      );
    } else {
      state = const AppAuthState.unauthenticated();
    }
  }

  void _listenToAuthChanges() {
    _authSubscription?.cancel();
    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      final session = authState.session ?? _authRepository.currentSession;
      final user = session?.user;

      if (user != null && session != null) {
        state = AppAuthState.authenticated(
          userId: user.id,
          email: user.email ?? '',
          displayName: user.userMetadata?['display_name'] ?? '',
          accessToken: session.accessToken,
        );
      } else {
        state = const AppAuthState.unauthenticated();
      }
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AppAuthState.loading();
    try {
      final response = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (response.user != null && response.session != null) {
        state = AppAuthState.authenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
          displayName: displayName,
          accessToken: response.session!.accessToken,
        );
      } else {
        state = const AppAuthState.unauthenticated();
      }
    } catch (e) {
      state = const AppAuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AppAuthState.loading();
    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null && response.session != null) {
        state = AppAuthState.authenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
          displayName: response.user!.userMetadata?['display_name'] ?? '',
          accessToken: response.session!.accessToken,
        );
      } else {
        state = const AppAuthState.unauthenticated();
      }
    } catch (e) {
      state = const AppAuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = const AppAuthState.loading();
    try {
      await _authRepository.signOut();
      state = const AppAuthState.unauthenticated();
    } catch (e) {
      // Even if sign out fails, set to unauthenticated
      state = const AppAuthState.unauthenticated();
      rethrow;
    }
  }

  Future<void> refreshSession() async {
    try {
      final response = await _authRepository.refreshSession();
      if (response.user != null && response.session != null) {
        state = AppAuthState.authenticated(
          userId: response.user!.id,
          email: response.user!.email ?? '',
          displayName: response.user!.userMetadata?['display_name'] ?? '',
          accessToken: response.session!.accessToken,
        );
      }
    } catch (e) {
      state = const AppAuthState.unauthenticated();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

// Providers
final supabaseClientProvider = Provider<supabase.SupabaseClient>((ref) {
  return supabase.Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthRepository(client);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AppAuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

// Convenience provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.maybeWhen(
    authenticated: (_, __, ___, ____) => true,
    orElse: () => false,
  );
});

// Provider to get access token
final accessTokenProvider = Provider<String?>((ref) {
  final authState = ref.watch(authControllerProvider);
  return authState.maybeWhen(
    authenticated: (String userId, String email, String displayName, String accessToken) => accessToken,
    orElse: () => null,
  );
});
