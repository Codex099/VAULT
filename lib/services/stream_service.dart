import 'package:http/http.dart' as http;

enum StreamSource {
  streamImdb,
}

class StreamService {
  // ─── Movie URLs ───────────────────────────────────────────────────────────
  static String getMovieUrl(String imdbId, String tmdbId, StreamSource source) {
    // We pass both so we can easily swap them.
    final id = imdbId.isNotEmpty ? imdbId : tmdbId;

    switch (source) {
      case StreamSource.streamImdb:
        return 'https://streamimdb.ru/embed/movie/$id';
    }
  }

  // ─── Series URLs ─────────────────────────────────────────────────────────────
  static String getSeriesUrl(
      String imdbId, String tmdbId, int season, int episode, StreamSource source) {
    final id = imdbId.isNotEmpty ? imdbId : tmdbId;

    switch (source) {
      case StreamSource.streamImdb:
        return 'https://streamimdb.ru/embed/tv/$id/$season/$episode';
    }
  }

  // ─── Availability check ───────────────────────────────────────────────────
  /// Returns true if the embed URL responds with HTTP 200/302/301.
  static Future<bool> checkAvailability(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));
      // 200 = OK, 301/302 = redirect (still valid)
      return response.statusCode == 200 ||
          response.statusCode == 301 ||
          response.statusCode == 302;
    } catch (_) {
      return false;
    }
  }

  /// Finds the first available source for a movie.
  /// Returns null if none is available.
  static Future<StreamSource?> findFirstAvailableMovie(String imdbId) async {
    for (final source in StreamSource.values) {
      final url = getMovieUrl(imdbId, '', source);
      final ok = await checkAvailability(url);
      if (ok) return source;
    }
    return null;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  static StreamSource nextSource(StreamSource current) {
    final sources = StreamSource.values;
    final idx = sources.indexOf(current);
    return sources[(idx + 1) % sources.length];
  }

  static String getSourceLabel(StreamSource source) {
    switch (source) {
      case StreamSource.streamImdb:
        return 'Stream IMDB';
    }
  }

  static String getSourceDescription(StreamSource source) {
    switch (source) {
      case StreamSource.streamImdb:
        return 'Serveur International';
    }
  }

  static List<StreamSource> get allSources => StreamSource.values;
}
