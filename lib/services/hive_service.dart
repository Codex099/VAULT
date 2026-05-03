import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../config.dart';
import '../models/progress_model.dart';

class HiveService {
  static late Box<WatchProgress> _progressBox;
  static late Box<FavoriteItem> _favoritesBox;
  static late Box<HistoryItem> _historyBox;
  static late Box<SeriesProgress> _seriesBox;
  static late Box<AppSettings> _settingsBox;
  static late Box<String> _recentSearchBox;

  static Future<void> init() async {
    _progressBox = await Hive.openBox<WatchProgress>(AppConfig.boxWatchProgress);
    _favoritesBox = await Hive.openBox<FavoriteItem>(AppConfig.boxFavorites);
    _historyBox = await Hive.openBox<HistoryItem>(AppConfig.boxWatchHistory);
    _seriesBox = await Hive.openBox<SeriesProgress>(AppConfig.boxSeriesProgress);
    _settingsBox = await Hive.openBox<AppSettings>(AppConfig.boxSettings);
    _recentSearchBox = await Hive.openBox<String>(AppConfig.boxRecentSearches);
  }

  // ─── Watch Progress ────────────────────────────────────────────────────────

  static Future<void> saveProgress({
    required String imdbId,
    required String tmdbId,
    required String title,
    required String posterUrl,
    String backdropUrl = '',
    required int positionSeconds,
    int totalDurationSeconds = 0,
    required String type,
    double rating = 0.0,
  }) async {
    final existing = _progressBox.get(imdbId);
    final progress = WatchProgress(
      imdbId: imdbId,
      title: title,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      lastPositionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds > 0
          ? totalDurationSeconds
          : (existing?.totalDurationSeconds ?? 0),
      lastWatchedDate: DateTime.now(),
      type: type,
      tmdbId: tmdbId,
      rating: rating,
    );
    await _progressBox.put(imdbId, progress);
  }

  static WatchProgress? getProgress(String imdbId) => _progressBox.get(imdbId);

  static List<WatchProgress> getContinueWatching() {
    return _progressBox.values
        .where((p) => !p.isCompleted && p.lastPositionSeconds > 10)
        .toList()
      ..sort((a, b) => b.lastWatchedDate.compareTo(a.lastWatchedDate));
  }

  static Future<void> removeProgress(String imdbId) async {
    await _progressBox.delete(imdbId);
  }

  // ─── Favorites ────────────────────────────────────────────────────────────

  static Future<void> addToFavorites(FavoriteItem item) async {
    await _favoritesBox.put(item.imdbId, item);
  }

  static Future<void> removeFromFavorites(String imdbId) async {
    await _favoritesBox.delete(imdbId);
  }

  static bool isFavorite(String imdbId) => _favoritesBox.containsKey(imdbId);

  static List<FavoriteItem> getAllFavorites() {
    return _favoritesBox.values.toList()
      ..sort((a, b) => b.addedDate.compareTo(a.addedDate));
  }

  // ─── Watch History ────────────────────────────────────────────────────────

  static Future<void> addToHistory(HistoryItem item) async {
    await _historyBox.put('${item.imdbId}_${item.watchedDate.millisecondsSinceEpoch}', item);
  }

  static List<HistoryItem> getAllHistory() {
    return _historyBox.values.toList()
      ..sort((a, b) => b.watchedDate.compareTo(a.watchedDate));
  }

  static Future<void> removeHistoryItem(String key) async {
    await _historyBox.delete(key);
  }

  static Future<void> clearHistory() async {
    await _historyBox.clear();
  }

  // ─── Series Progress ──────────────────────────────────────────────────────

  static Future<void> saveSeriesProgress({
    required String imdbId,
    required int season,
    required int episode,
    int positionSeconds = 0,
  }) async {
    final existing = _seriesBox.get(imdbId) ??
        SeriesProgress(imdbId: imdbId);

    existing
      ..lastSeason = season
      ..lastEpisode = episode
      ..lastPositionSeconds = positionSeconds;
    existing.markEpisodeWatched(season, episode);

    await _seriesBox.put(imdbId, existing);
  }

  static SeriesProgress? getSeriesProgress(String imdbId) =>
      _seriesBox.get(imdbId);

  static bool isEpisodeWatched(String imdbId, int season, int episode) {
    return _seriesBox.get(imdbId)?.isEpisodeWatched(season, episode) ?? false;
  }

  // ─── Settings ─────────────────────────────────────────────────────────────

  static AppSettings getSettings() {
    return _settingsBox.get('settings') ?? AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put('settings', settings);
  }

  // ─── Recent Searches ──────────────────────────────────────────────────────

  static List<String> getRecentSearches() {
    return _recentSearchBox.values.toList();
  }

  static Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    // Remove duplicate and keep latest at front
    final searches = getRecentSearches()
        .where((s) => s.toLowerCase() != query.toLowerCase())
        .take(9)
        .toList();
    await _recentSearchBox.clear();
    for (final s in [query, ...searches]) {
      await _recentSearchBox.add(s);
    }
  }

  static Future<void> clearRecentSearches() async {
    await _recentSearchBox.clear();
  }

  // ─── Export / Import ──────────────────────────────────────────────────────

  static String exportData() {
    final favorites = getAllFavorites()
        .map((f) => {
              'imdbId': f.imdbId,
              'title': f.title,
              'type': f.type,
              'rating': f.rating,
              'year': f.year,
              'addedDate': f.addedDate.toIso8601String(),
            })
        .toList();

    return jsonEncode({'favorites': favorites});
  }

  static Future<void> importData(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    // Import favorites
    final favorites = data['favorites'] as List<dynamic>? ?? [];
    for (final f in favorites) {
      final item = FavoriteItem(
        imdbId: f['imdbId'] as String,
        title: f['title'] as String,
        posterUrl: '',
        type: f['type'] as String,
        rating: (f['rating'] as num?)?.toDouble() ?? 0.0,
        year: f['year'] as String? ?? '',
        addedDate: DateTime.parse(f['addedDate'] as String),
        tmdbId: '',
      );
      await addToFavorites(item);
    }
  }
}
