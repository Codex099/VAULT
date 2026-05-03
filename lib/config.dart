/// CineStream — Configuration
/// Replace the placeholder values below with your actual API keys.

class AppConfig {
  AppConfig._();

  // ─── TMDB ───────────────────────────────────────────────────────────────────
  /// Get your free key at: https://www.themoviedb.org/settings/api
  static const String tmdbApiKey = 'e0d2a0d265d6d31ec77e61b5c98398ad';
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBase = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBase = 'https://image.tmdb.org/t/p/w1280';
  static const String tmdbOriginalBase = 'https://image.tmdb.org/t/p/original';

  // ─── OpenSubtitles ──────────────────────────────────────────────────────────
  /// Get your free key at: https://www.opensubtitles.com/en/consumers
  static const String openSubsApiKey = 'YDm8qOloQ2QbMErVKqUnQIUaqCfJsB67';
  static const String openSubsBaseUrl = 'https://api.opensubtitles.com/api/v1';

  // ─── App Settings ────────────────────────────────────────────────────────────
  static const int cacheExpiryHours = 6;
  static const int searchDebounceMs = 400;
  static const int pageSize = 20;
  static const double continueWatchingThreshold = 0.95; // 95% = "watched"

  // ─── Hive Box Names ──────────────────────────────────────────────────────────
  static const String boxWatchProgress = 'watchProgress';
  static const String boxFavorites = 'favorites';
  static const String boxWatchHistory = 'watchHistory';
  static const String boxSeriesProgress = 'seriesProgress';
  static const String boxCache = 'tmdbCache';
  static const String boxSettings = 'settings';
  static const String boxRecentSearches = 'recentSearches';
}
