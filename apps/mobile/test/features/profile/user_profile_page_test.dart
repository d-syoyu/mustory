import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/core/auth/auth_controller.dart';
import 'package:mustory_mobile/core/auth/auth_state.dart';
import 'package:mustory_mobile/features/profile/application/profile_controller.dart';
import 'package:mustory_mobile/features/profile/data/profile_repository.dart';
import 'package:mustory_mobile/features/profile/domain/user_profile.dart';
import 'package:mustory_mobile/features/profile/presentation/user_profile_page.dart';

class _FakeProfileRepository extends ProfileRepository {
  _FakeProfileRepository() : super(Dio(BaseOptions()));

  final UserProfile profile = const UserProfile(
    id: 'user-1',
    username: 'tester',
    displayName: 'Tester',
    email: 'tester@example.com',
    trackCount: 3,
    storyCount: 1,
    followerCount: 10,
    followingCount: 5,
    isFollowedByMe: false,
  );

  @override
  Future<UserProfile> getUserProfile(String userId) async => profile;
}

class _FakeAuthController extends StateNotifier<AppAuthState>
    implements AuthController {
  _FakeAuthController()
      : super(const AppAuthState.authenticated(
          userId: 'current-user',
          email: 'tester@example.com',
          displayName: 'Tester',
          accessToken: 'token',
        ));

  @override
  Future<void> refreshSession() async {}

  @override
  Future<void> signIn({required String email, required String password}) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUp(
      {required String email,
      required String password,
      required String displayName}) async {}
}

void main() {
  testWidgets('プロフィール画面にフォロー状態と統計が表示されること',
      (tester) async {
    final fakeRepo = _FakeProfileRepository();
    final fakeAuth = _FakeAuthController();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          profileRepositoryProvider.overrideWithValue(fakeRepo),
          authControllerProvider.overrideWith((ref) => fakeAuth),
        ],
        child: const MaterialApp(
          home: UserProfilePage(userId: 'user-1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('tester@example.com'), findsOneWidget);
    expect(find.text('@tester'), findsOneWidget);
    expect(find.text('フォロワー'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('フォロー中'), findsWidgets); // label + button state text
    expect(find.text('5'), findsOneWidget);
    expect(find.text('フォローする'), findsOneWidget);
  });
}
