import 'package:hooks_riverpod/hooks_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(),
);

class AnalyticsService {
  Future<void> track(String event, {Map<String, dynamic>? properties}) async {
    // TODO: connect PostHog/Sentry.
  }
}
