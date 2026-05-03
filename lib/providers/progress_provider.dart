import 'package:flutter/foundation.dart';
import '../models/progress_model.dart';
import '../services/hive_service.dart';

class ProgressProvider extends ChangeNotifier {
  List<WatchProgress> _continueWatching = [];
  List<HistoryItem> _history = [];

  List<WatchProgress> get continueWatching => _continueWatching;
  List<HistoryItem> get history => _history;
  bool get hasContinueWatching => _continueWatching.isNotEmpty;

  void load() {
    _continueWatching = HiveService.getContinueWatching();
    _history = HiveService.getAllHistory();
    notifyListeners();
  }

  Future<void> saveProgress({
    required String imdbId,
    required String tmdbId,
    required String title,
    required String posterUrl,
    String backdropUrl = '',
    required int positionSeconds,
    int totalDurationSeconds = 0,
    required String type,
  }) async {
    await HiveService.saveProgress(
      imdbId: imdbId,
      tmdbId: tmdbId,
      title: title,
      posterUrl: posterUrl,
      backdropUrl: backdropUrl,
      positionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds,
      type: type,
    );
    load();
  }

  WatchProgress? getProgress(String imdbId) => HiveService.getProgress(imdbId);

  Future<void> addToHistory({
    required String imdbId,
    required String tmdbId,
    required String title,
    required String posterUrl,
    required String type,
    int? season,
    int? episode,
  }) async {
    final item = HistoryItem(
      imdbId: imdbId,
      title: title,
      posterUrl: posterUrl,
      watchedDate: DateTime.now(),
      type: type,
      season: season,
      episode: episode,
      tmdbId: tmdbId,
    );
    await HiveService.addToHistory(item);
    load();
  }

  Future<void> clearHistory() async {
    await HiveService.clearHistory();
    load();
  }

  Future<void> removeHistoryItem(String key) async {
    await HiveService.removeHistoryItem(key);
    load();
  }

  Future<void> removeProgress(String imdbId) async {
    await HiveService.removeProgress(imdbId);
    load();
  }

  // Group history by date for display
  Map<String, List<HistoryItem>> get groupedHistory {
    final groups = <String, List<HistoryItem>>{};
    final now = DateTime.now();

    for (final item in _history) {
      final diff = now.difference(item.watchedDate);
      String group;
      if (diff.inDays == 0) {
        group = "Aujourd'hui";
      } else if (diff.inDays == 1) {
        group = 'Hier';
      } else if (diff.inDays <= 7) {
        group = 'Cette semaine';
      } else {
        group = 'Plus tôt';
      }
      groups.putIfAbsent(group, () => []).add(item);
    }
    return groups;
  }
}
