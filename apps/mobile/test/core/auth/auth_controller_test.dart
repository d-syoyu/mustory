import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/auth/auth_state.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';
import 'package:mustory_mobile/core/auth/auth_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

@GenerateMocks([AuthRepository, supabase.SupabaseClient])
import 'auth_controller_test.mocks.dart';

void main() {
  group('AuthController', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );
      when(mockAuthRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be unauthenticated when no user', () {
      // Arrange
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.currentSession).thenReturn(null);

      // Act
      final state = container.read(authControllerProvider);

      // Assert
      expect(state, const AppAuthState.unauthenticated());
    });

    test('isAuthenticatedProvider should return false when unauthenticated', () {
      // Arrange
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.currentSession).thenReturn(null);

      // Act
      final isAuthenticated = container.read(isAuthenticatedProvider);

      // Assert
      expect(isAuthenticated, false);
    });

    test('isAuthenticatedProvider should return true when authenticated', () {
      // Arrange
      final mockUser = _createMockUser();
      final mockSession = _createMockSession();
      when(mockAuthRepository.currentUser).thenReturn(mockUser);
      when(mockAuthRepository.currentSession).thenReturn(mockSession);

      // Rebuild container to trigger auth check
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      // Act
      final isAuthenticated = container.read(isAuthenticatedProvider);

      // Assert
      expect(isAuthenticated, true);
    });

    test('accessTokenProvider should return null when unauthenticated', () {
      // Arrange
      when(mockAuthRepository.currentUser).thenReturn(null);
      when(mockAuthRepository.currentSession).thenReturn(null);

      // Act
      final accessToken = container.read(accessTokenProvider);

      // Assert
      expect(accessToken, null);
    });

    test('accessTokenProvider should return token when authenticated', () {
      // Arrange
      final mockUser = _createMockUser();
      final mockSession = _createMockSession();
      when(mockAuthRepository.currentUser).thenReturn(mockUser);
      when(mockAuthRepository.currentSession).thenReturn(mockSession);

      // Rebuild container
      container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
      );

      // Act
      final accessToken = container.read(accessTokenProvider);

      // Assert
      expect(accessToken, 'test_access_token');
    });
  });
}

// Helper functions to create mock objects
supabase.User _createMockUser() {
  return supabase.User(
    id: 'test_user_id',
    appMetadata: {},
    userMetadata: {'display_name': 'Test User'},
    aud: 'authenticated',
    createdAt: DateTime.now().toIso8601String(),
  );
}

supabase.Session _createMockSession() {
  return supabase.Session(
    accessToken: 'test_access_token',
    tokenType: 'bearer',
    user: _createMockUser(),
  );
}
