import 'package:hive/hive.dart';

part 'progress_model.g.dart';

// ─── Watch Progress ───────────────────────────────────────────────────────────

@HiveType(typeId: 40)
class WatchProgress extends HiveObject {
  @HiveField(0) String imdbId;
  @HiveField(1) String title;
  @HiveField(2) String posterUrl;
  @HiveField(3) String backdropUrl;
  @HiveField(4) int lastPositionSeconds;
  @HiveField(5) int totalDurationSeconds;
  @HiveField(6) DateTime lastWatchedDate;
  @HiveField(7) String type;
  @HiveField(8) String tmdbId;
  @HiveField(9) double rating;

  WatchProgress({
    required this.imdbId, required this.title, required this.posterUrl,
    this.backdropUrl = '', required this.lastPositionSeconds,
    this.totalDurationSeconds = 0, required this.lastWatchedDate,
    required this.type, required this.tmdbId, this.rating = 0.0,
  });

  double get progressPercent =>
      totalDurationSeconds > 0 ? lastPositionSeconds / totalDurationSeconds : 0.0;

  bool get isCompleted => progressPercent >= 0.95;
}

// ─── Favorite Item ────────────────────────────────────────────────────────────

@HiveType(typeId: 41)
class FavoriteItem extends HiveObject {
  @HiveField(0) String imdbId;
  @HiveField(1) String title;
  @HiveField(2) String posterUrl;
  @HiveField(3) String type;
  @HiveField(4) double rating;
  @HiveField(5) String year;
  @HiveField(6) List<String> genres;
  @HiveField(7) DateTime addedDate;
  @HiveField(8) String tmdbId;

  FavoriteItem({
    required this.imdbId, required this.title, required this.posterUrl,
    required this.type, this.rating = 0.0, this.year = '',
    this.genres = const [], required this.addedDate, required this.tmdbId,
  });
}

// ─── Watch History Item ───────────────────────────────────────────────────────

@HiveType(typeId: 42)
class HistoryItem extends HiveObject {
  @HiveField(0) String imdbId;
  @HiveField(1) String title;
  @HiveField(2) String posterUrl;
  @HiveField(3) DateTime watchedDate;
  @HiveField(4) String type;
  @HiveField(5) int? season;
  @HiveField(6) int? episode;
  @HiveField(7) String tmdbId;

  HistoryItem({
    required this.imdbId, required this.title, required this.posterUrl,
    required this.watchedDate, required this.type,
    this.season, this.episode, required this.tmdbId,
  });
}

// ─── Series Progress ──────────────────────────────────────────────────────────

@HiveType(typeId: 43)
class SeriesProgress extends HiveObject {
  @HiveField(0) String imdbId;
  @HiveField(1) int lastSeason;
  @HiveField(2) int lastEpisode;
  @HiveField(3) int lastPositionSeconds;
  @HiveField(4) List<String> episodesWatched;
  @HiveField(5) int totalEpisodes;

  SeriesProgress({
    required this.imdbId, this.lastSeason = 1, this.lastEpisode = 1,
    this.lastPositionSeconds = 0, this.episodesWatched = const [],
    this.totalEpisodes = 0,
  });

  bool isEpisodeWatched(int season, int episode) {
    final code = 'S${season.toString().padLeft(2, '0')}E${episode.toString().padLeft(2, '0')}';
    return episodesWatched.contains(code);
  }

  void markEpisodeWatched(int season, int episode) {
    final code = 'S${season.toString().padLeft(2, '0')}E${episode.toString().padLeft(2, '0')}';
    if (!episodesWatched.contains(code)) {
      episodesWatched = [...episodesWatched, code];
    }
  }
}

// ─── App Settings ─────────────────────────────────────────────────────────────

@HiveType(typeId: 44)
class AppSettings extends HiveObject {
  @HiveField(0) String language;
  @HiveField(1) String subtitleLanguage;
  @HiveField(2) bool autoPlay;
  @HiveField(3) bool saveHistory;
  @HiveField(4) String defaultStreamSource;
  @HiveField(5) bool hasSeenOnboarding;

  AppSettings({
    this.language = 'fr', this.subtitleLanguage = 'ar',
    this.autoPlay = true, this.saveHistory = true,
    this.defaultStreamSource = 'vidsrc',
    this.hasSeenOnboarding = false,
  });
}
