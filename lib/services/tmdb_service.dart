import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../config.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../models/episode_model.dart';
import '../models/actor_model.dart';

class TmdbService {
  static const String _defaultLang = 'fr-FR';
  static const String _arabicLang = 'ar-SA';
  static late Box _cacheBox;

  static Future<void> init() async {
    _cacheBox = await Hive.openBox(AppConfig.boxCache);
  }

  // ─── Cache helpers ────────────────────────────────────────────────────────

  static dynamic _getCached(String key) {
    final cached = _cacheBox.get(key);
    if (cached == null) return null;
    final ts = _cacheBox.get('${key}_ts') as int?;
    if (ts == null) return null;
    final age = DateTime.now().millisecondsSinceEpoch - ts;
    final maxAge = AppConfig.cacheExpiryHours * 3600 * 1000;
    if (age > maxAge) return null;
    return cached;
  }

  static Future<void> _setCache(String key, dynamic value) async {
    await _cacheBox.put(key, value);
    await _cacheBox.put('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  // ─── HTTP with retry ──────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _get(
    String path, {
    Map<String, String>? params,
    String? lang,
  }) async {
    final queryParams = {
      'api_key': AppConfig.tmdbApiKey,
      'language': lang ?? _defaultLang,
      ...?params,
    };

    final uri = Uri.parse('${AppConfig.tmdbBaseUrl}$path')
        .replace(queryParameters: queryParams);

    const maxRetries = 3;
    for (var i = 0; i < maxRetries; i++) {
      try {
        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }
        if (response.statusCode == 429) {
          await Future.delayed(Duration(seconds: (i + 1) * 2));
          continue;
        }
        throw Exception('TMDB error ${response.statusCode}');
      } on TimeoutException {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: i + 1));
      } catch (e) {
        if (i == maxRetries - 1) rethrow;
        await Future.delayed(Duration(seconds: i + 1));
      }
    }
    throw Exception('Failed after $maxRetries retries');
  }

  static Future<List<dynamic>> _getPagedResults(
    String path, {
    int page = 1,
    String? lang,
    Map<String, String>? extra,
  }) async {
    final cacheKey = '${path}_p${page}_${lang ?? _defaultLang}';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      return jsonDecode(jsonEncode(cached)) as List<dynamic>;
    }

    final data = await _get(path,
        params: {'page': page.toString(), ...?extra}, lang: lang);
    final results = data['results'] as List<dynamic>? ?? [];
    await _setCache(cacheKey, results);
    return results;
  }

  // ─── Movies ───────────────────────────────────────────────────────────────

  static Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final results = await _getPagedResults('/movie/popular', page: page);
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final results = await _getPagedResults('/movie/top_rated', page: page);
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<MovieModel>> getNowPlayingMovies() async {
    final results = await _getPagedResults('/movie/now_playing');
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<MovieModel>> getUpcomingMovies() async {
    final results = await _getPagedResults('/movie/upcoming');
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Series ───────────────────────────────────────────────────────────────

  static Future<List<SeriesModel>> getPopularSeries({int page = 1}) async {
    final results = await _getPagedResults('/tv/popular', page: page);
    return results
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<SeriesModel>> getTopRatedSeries({int page = 1}) async {
    final results = await _getPagedResults('/tv/top_rated', page: page);
    return results
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<SeriesModel>> getOnAirSeries() async {
    final results = await _getPagedResults('/tv/on_the_air');
    return results
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Trending ─────────────────────────────────────────────────────────────

  static Future<List<dynamic>> getTrendingAll({int page = 1}) async {
    final cacheKey = 'trending_all_week_p$page';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      return jsonDecode(jsonEncode(cached)) as List<dynamic>;
    }

    final data = await _get('/trending/all/week', params: {'page': '$page'});
    final results = data['results'] as List<dynamic>? ?? [];
    await _setCache(cacheKey, results);
    return results;
  }

  static Future<List<MovieModel>> getTrendingMovies() async {
    final all = await getTrendingAll();
    return all
        .where((e) =>
            (e as Map<String, dynamic>)['media_type'] == 'movie')
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .take(10)
        .toList();
  }

  // ─── Details ──────────────────────────────────────────────────────────────

  static Future<MovieModel> getMovieDetails(int tmdbId) async {
    final cacheKey = 'movie_detail_$tmdbId';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      return MovieModel.fromJson(
          jsonDecode(jsonEncode(cached)) as Map<String, dynamic>);
    }

    final data = await _get(
      '/movie/$tmdbId',
      params: {
        'append_to_response': 'credits,videos,similar,recommendations,external_ids',
      },
    );
    await _setCache(cacheKey, data);

    final externalIds = data['external_ids'] as Map<String, dynamic>?;
    final imdbId = externalIds?['imdb_id'] as String?;

    var movie = MovieModel.fromJson(data);
    if (imdbId != null) {
      movie = movie.copyWith(imdbId: imdbId);
    }
    return movie;
  }

  static Future<SeriesModel> getSeriesDetails(int tmdbId) async {
    final cacheKey = 'series_detail_$tmdbId';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      return SeriesModel.fromJson(
          jsonDecode(jsonEncode(cached)) as Map<String, dynamic>);
    }

    final data = await _get(
      '/tv/$tmdbId',
      params: {
        'append_to_response': 'credits,videos,similar,recommendations,external_ids',
      },
    );
    await _setCache(cacheKey, data);

    final externalIds = data['external_ids'] as Map<String, dynamic>?;
    final imdbId = externalIds?['imdb_id'] as String?;

    var series = SeriesModel.fromJson(data);
    if (imdbId != null) {
      series = series.copyWith(imdbId: imdbId);
    }
    return series;
  }

  static Future<SeasonDetail> getSeasonDetails(
      int tmdbId, int seasonNumber) async {
    final cacheKey = 'season_${tmdbId}_$seasonNumber';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      return SeasonDetail.fromJson(
          jsonDecode(jsonEncode(cached)) as Map<String, dynamic>);
    }

    final data = await _get('/tv/$tmdbId/season/$seasonNumber');
    await _setCache(cacheKey, data);
    return SeasonDetail.fromJson(data);
  }

  static Future<String?> getImdbId(int tmdbId, String type) async {
    final cacheKey = 'imdb_id_${type}_$tmdbId';
    final cached = _getCached(cacheKey);
    if (cached != null) return cached as String?;

    try {
      final endpoint =
          type == 'movie' ? '/movie/$tmdbId/external_ids' : '/tv/$tmdbId/external_ids';
      final data = await _get(endpoint);
      final imdbId = data['imdb_id'] as String?;
      if (imdbId != null) await _setCache(cacheKey, imdbId);
      return imdbId;
    } catch (_) {
      return null;
    }
  }

  // ─── Actor ────────────────────────────────────────────────────────────────

  static Future<ActorModel> getActorDetails(int personId) async {
    final cacheKey = 'actor_$personId';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      return ActorModel.fromJson(
          jsonDecode(jsonEncode(cached)) as Map<String, dynamic>);
    }

    final data = await _get(
      '/person/$personId',
      params: {'append_to_response': 'combined_credits'},
    );
    await _setCache(cacheKey, data);
    return ActorModel.fromJson(data);
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  static Future<List<dynamic>> searchMulti(String query,
      {int page = 1}) async {
    final data = await _get('/search/multi',
        params: {'query': query, 'page': '$page'});
    return data['results'] as List<dynamic>? ?? [];
  }

  // ─── Genres ───────────────────────────────────────────────────────────────

  static Future<List<GenreModel>> getMovieGenres() async {
    const cacheKey = 'movie_genres';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      final list = jsonDecode(jsonEncode(cached)) as List<dynamic>;
      return list.map((e) => GenreModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    final data = await _get('/genre/movie/list');
    final genres = data['genres'] as List<dynamic>? ?? [];
    await _setCache(cacheKey, genres);
    return genres
        .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<GenreModel>> getTvGenres() async {
    const cacheKey = 'tv_genres';
    final cached = _getCached(cacheKey);
    if (cached != null) {
      final list = jsonDecode(jsonEncode(cached)) as List<dynamic>;
      return list.map((e) => GenreModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    final data = await _get('/genre/tv/list');
    final genres = data['genres'] as List<dynamic>? ?? [];
    await _setCache(cacheKey, genres);
    return genres
        .map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Discover by genre ────────────────────────────────────────────────────

  static Future<List<MovieModel>> discoverMoviesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final results = await _getPagedResults(
      '/discover/movie',
      page: page,
      extra: {
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
      },
    );
    return results
        .map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<List<SeriesModel>> discoverSeriesByGenre(
    int genreId, {
    int page = 1,
  }) async {
    final results = await _getPagedResults(
      '/discover/tv',
      page: page,
      extra: {
        'with_genres': genreId.toString(),
        'sort_by': 'popularity.desc',
      },
    );
    return results
        .map((e) => SeriesModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
