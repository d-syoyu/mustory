import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_state.freezed.dart';

@freezed
class AppAuthState with _$AppAuthState {
  const factory AppAuthState.initial() = _Initial;
  const factory AppAuthState.authenticated({
    required String userId,
    required String email,
    required String displayName,
    required String accessToken,
  }) = _Authenticated;
  const factory AppAuthState.unauthenticated() = _Unauthenticated;
  const factory AppAuthState.loading() = _Loading;
}
