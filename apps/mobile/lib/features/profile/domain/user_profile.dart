// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    @Default('') String username,
    @Default('') String displayName,
    @Default('') String email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    String? location,
    @JsonKey(name: 'link_url') String? linkUrl,
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
    @Default('') String username,
    @Default('') String displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? email,
  }) = _UserSummary;

  factory UserSummary.fromJson(Map<String, dynamic> json) =>
      _$UserSummaryFromJson(json);
}

class UserPage {
  final List<UserSummary> items;
  final String? nextCursor;

  UserPage({
    required this.items,
    required this.nextCursor,
  });
}
