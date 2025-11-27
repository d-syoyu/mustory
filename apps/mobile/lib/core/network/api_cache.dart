/// Simple in-memory cache for API responses
/// Caches responses for a configurable duration to reduce redundant API calls
class ApiCache {
  static final ApiCache _instance = ApiCache._internal();
  factory ApiCache() => _instance;
  ApiCache._internal();

  final Map<String, _CacheEntry> _cache = {};

  /// Default cache duration (5 minutes)
  static const Duration defaultDuration = Duration(minutes: 5);

  /// Short cache duration for frequently changing data (30 seconds)
  static const Duration shortDuration = Duration(seconds: 30);

  /// Get cached data if available and not expired
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (DateTime.now().isAfter(entry.expiry)) {
      _cache.remove(key);
      return null;
    }

    return entry.data as T?;
  }

  /// Store data in cache
  void set<T>(String key, T data, {Duration duration = defaultDuration}) {
    _cache[key] = _CacheEntry(
      data: data,
      expiry: DateTime.now().add(duration),
    );
  }

  /// Remove specific key from cache
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Remove all keys matching a pattern
  void invalidatePattern(String pattern) {
    _cache.removeWhere((key, _) => key.contains(pattern));
  }

  /// Clear all cached data
  void clear() {
    _cache.clear();
  }

  /// Get cache size (for debugging)
  int get size => _cache.length;
}

class _CacheEntry {
  final dynamic data;
  final DateTime expiry;

  _CacheEntry({required this.data, required this.expiry});
}
