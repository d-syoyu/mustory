import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String displayName,
    required String email,
    @Default(0) int trackCount,
    @Default(0) int storyCount,
    @Default(0) int followerCount,
    @Default(0) int followingCount,
    @Default(false) bool isFollowedByMe,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}

@freezed
class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String id,
    required String displayName,
    String? email,
  }) = _UserSummary;

  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryFromJson(json);
}
