import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mustory_mobile/features/tracks/domain/track.dart';
import 'package:mustory_mobile/features/tracks/data/tracks_repository.dart';
import 'package:mustory_mobile/features/tracks/application/tracks_controller.dart';
import 'package:mustory_mobile/features/profile/data/profile_repository.dart';
import 'package:mustory_mobile/features/profile/domain/user_profile.dart';
import 'package:mustory_mobile/features/profile/application/profile_controller.dart';

const _searchHistoryKey = 'search_history';
const _maxHistoryItems = 10;

/// Search filter type
enum SearchFilterType { all, tracks, users }

/// Sort option
enum SearchSortOption { relevance, newest, popular }

/// Search state
class SearchState {
  final List<Track> trackResults;
  final List<UserSummary> userResults;
  final bool isLoading;
  final String? error;
  final String query;
  final List<String> searchHistory;
  final SearchFilterType filterType;
  final SearchSortOption sortOption;
  final List<Track> trendingTracks;
  final bool isTrendingLoading;

  const SearchState({
    this.trackResults = const [],
    this.userResults = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
    this.searchHistory = const [],
    this.filterType = SearchFilterType.all,
    this.sortOption = SearchSortOption.relevance,
    this.trendingTracks = const [],
    this.isTrendingLoading = false,
  });

  // Total result count
  int get totalResultCount => trackResults.length + userResults.length;

  // Results based on filter
  List<Track> get filteredTrackResults {
    if (filterType == SearchFilterType.users) return [];
    return trackResults;
  }

  List<UserSummary> get filteredUserResults {
    if (filterType == SearchFilterType.tracks) return [];
    return userResults;
  }

  SearchState copyWith({
    List<Track>? trackResults,
    List<UserSummary>? userResults,
    bool? isLoading,
    String? error,
    String? query,
    List<String>? searchHistory,
    SearchFilterType? filterType,
    SearchSortOption? sortOption,
    List<Track>? trendingTracks,
    bool? isTrendingLoading,
  }) {
    return SearchState(
      trackResults: trackResults ?? this.trackResults,
      userResults: userResults ?? this.userResults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      searchHistory: searchHistory ?? this.searchHistory,
      filterType: filterType ?? this.filterType,
      sortOption: sortOption ?? this.sortOption,
      trendingTracks: trendingTracks ?? this.trendingTracks,
      isTrendingLoading: isTrendingLoading ?? this.isTrendingLoading,
    );
  }
}

/// Search controller with debounce
class SearchController extends StateNotifier<SearchState> {
  SearchController(this._tracksRepository, this._profileRepository)
      : super(const SearchState()) {
    _loadSearchHistory();
    _loadTrendingTracks();
  }

  final TracksRepository _tracksRepository;
  final ProfileRepository _profileRepository;
  Timer? _debounceTimer;

  static const _debounceDuration = Duration(milliseconds: 400);

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_searchHistoryKey) ?? [];
    state = state.copyWith(searchHistory: history);
  }

  Future<void> _loadTrendingTracks() async {
    state = state.copyWith(isTrendingLoading: true);
    try {
      final tracks = await _tracksRepository.getTracks(limit: 10);
      // Sort by view count for trending
      tracks.sort((a, b) => b.viewCount.compareTo(a.viewCount));
      state = state.copyWith(
        trendingTracks: tracks.take(5).toList(),
        isTrendingLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isTrendingLoading: false);
    }
  }

  Future<void> _saveSearchHistory(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    var history = List<String>.from(state.searchHistory);

    // Remove if already exists
    history.remove(trimmed);
    // Add to beginning
    history.insert(0, trimmed);
    // Limit size
    if (history.length > _maxHistoryItems) {
      history = history.sublist(0, _maxHistoryItems);
    }

    await prefs.setStringList(_searchHistoryKey, history);
    state = state.copyWith(searchHistory: history);
  }

  /// Search with debounce (called on every keystroke)
  void searchWithDebounce(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      state = state.copyWith(
        trackResults: [],
        userResults: [],
        isLoading: false,
        query: '',
        error: null,
      );
      return;
    }

    // Show loading immediately but debounce actual search
    state = state.copyWith(query: query);

    _debounceTimer = Timer(_debounceDuration, () {
      _executeSearch(query);
    });
  }

  /// Execute search immediately (called when tapping history/suggestions)
  Future<void> search(String query) async {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      clear();
      return;
    }
    await _executeSearch(query);
  }

  Future<void> _executeSearch(String query) async {
    state = state.copyWith(isLoading: true, error: null, query: query);

    try {
      // Search both tracks and users in parallel
      final results = await Future.wait([
        _tracksRepository.searchTracks(query: query.trim()),
        _profileRepository.searchUsers(query: query.trim()),
      ]);

      var tracks = results[0] as List<Track>;
      final users = results[1] as List<UserSummary>;

      // Apply sorting
      tracks = _sortTracks(tracks);

      // Save to history on successful search
      await _saveSearchHistory(query);

      state = state.copyWith(
        trackResults: tracks,
        userResults: users,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        trackResults: [],
        userResults: [],
      );
    }
  }

  List<Track> _sortTracks(List<Track> tracks) {
    final sorted = List<Track>.from(tracks);
    switch (state.sortOption) {
      case SearchSortOption.relevance:
        // Keep original order (relevance from API)
        break;
      case SearchSortOption.newest:
        sorted.sort((a, b) {
          final aDate = a.createdAt ?? DateTime(1970);
          final bDate = b.createdAt ?? DateTime(1970);
          return bDate.compareTo(aDate);
        });
        break;
      case SearchSortOption.popular:
        sorted.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
    }
    return sorted;
  }

  void setFilterType(SearchFilterType type) {
    state = state.copyWith(filterType: type);
  }

  void setSortOption(SearchSortOption option) {
    state = state.copyWith(sortOption: option);
    // Re-sort existing results
    if (state.trackResults.isNotEmpty) {
      state = state.copyWith(trackResults: _sortTracks(state.trackResults));
    }
  }

  Future<void> removeFromHistory(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final history = List<String>.from(state.searchHistory);
    history.remove(query);
    await prefs.setStringList(_searchHistoryKey, history);
    state = state.copyWith(searchHistory: history);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
    state = state.copyWith(searchHistory: []);
  }

  void clear() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      trackResults: [],
      userResults: [],
      isLoading: false,
      query: '',
      error: null,
    );
  }
}

/// Search controller provider
final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final tracksRepository = ref.watch(tracksRepositoryProvider);
  final profileRepository = ref.watch(profileRepositoryProvider);
  return SearchController(tracksRepository, profileRepository);
});
