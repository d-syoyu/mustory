import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';

const _kRecommendationPageSize = 12;

/// Fetches recommended tracks using the API-backed repository.
final recommendedTracksProvider = FutureProvider<List<Track>>((ref) async {
  final repository = ref.watch(tracksRepositoryProvider);
  return repository.getRecommendedTracks(limit: _kRecommendationPageSize);
});
