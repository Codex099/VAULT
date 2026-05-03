import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../services/tmdb_service.dart';

class MovieProvider extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────────────────
  List<MovieModel> _trending = [];
  List<MovieModel> _popular = [];
  List<MovieModel> _topRated = [];
  List<MovieModel> _nowPlaying = [];
  List<MovieModel> _upcoming = [];
  List<SeriesModel> _popularSeries = [];
  List<SeriesModel> _topRatedSeries = [];
  List<SeriesModel> _onAirSeries = [];
  List<GenreModel> _movieGenres = [];
  List<GenreModel> _tvGenres = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _popularPage = 1;
  bool _hasMorePopular = true;

  // ─── Search state ─────────────────────────────────────────────────────────
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = '';

  // ─── Getters ──────────────────────────────────────────────────────────────
  List<MovieModel> get trending => _trending;
  List<MovieModel> get popular => _popular;
  List<MovieModel> get topRated => _topRated;
  List<MovieModel> get nowPlaying => _nowPlaying;
  List<MovieModel> get upcoming => _upcoming;
  List<SeriesModel> get popularSeries => _popularSeries;
  List<SeriesModel> get topRatedSeries => _topRatedSeries;
  List<SeriesModel> get onAirSeries => _onAirSeries;
  List<GenreModel> get movieGenres => _movieGenres;
  List<GenreModel> get tvGenres => _tvGenres;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSearching => _isSearching;
  String? get error => _error;
  List<dynamic> get searchResults => _searchResults;
  String get lastQuery => _lastQuery;

  // ─── Load home data ───────────────────────────────────────────────────────
  Future<void> loadHomeData() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        TmdbService.getTrendingMovies(),
        TmdbService.getPopularMovies(),
        TmdbService.getTopRatedMovies(),
        TmdbService.getNowPlayingMovies(),
        TmdbService.getUpcomingMovies(),
        TmdbService.getPopularSeries(),
        TmdbService.getTopRatedSeries(),
        TmdbService.getOnAirSeries(),
        TmdbService.getMovieGenres(),
        TmdbService.getTvGenres(),
      ]);

      _trending = results[0] as List<MovieModel>;
      _popular = results[1] as List<MovieModel>;
      _topRated = results[2] as List<MovieModel>;
      _nowPlaying = results[3] as List<MovieModel>;
      _upcoming = results[4] as List<MovieModel>;
      _popularSeries = results[5] as List<SeriesModel>;
      _topRatedSeries = results[6] as List<SeriesModel>;
      _onAirSeries = results[7] as List<SeriesModel>;
      _movieGenres = results[8] as List<GenreModel>;
      _tvGenres = results[9] as List<GenreModel>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Load more popular ────────────────────────────────────────────────────
  Future<void> loadMorePopular() async {
    if (_isLoadingMore || !_hasMorePopular) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      _popularPage++;
      final more = await TmdbService.getPopularMovies(page: _popularPage);
      if (more.isEmpty) {
        _hasMorePopular = false;
      } else {
        _popular = [..._popular, ...more];
      }
    } catch (_) {
      _popularPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // ─── Search ───────────────────────────────────────────────────────────────
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _lastQuery = '';
      notifyListeners();
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;
    _isSearching = true;
    notifyListeners();

    try {
      final results = await TmdbService.searchMulti(query);
      if (query == _lastQuery) {
        _searchResults = results;
      }
    } catch (_) {
      _searchResults = [];
    } finally {
      if (query == _lastQuery) {
        _isSearching = false;
        notifyListeners();
      }
    }
  }

  void clearSearch() {
    _searchResults = [];
    _lastQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  // ─── Genre movies ─────────────────────────────────────────────────────────
  Future<List<MovieModel>> getMoviesByGenre(int genreId,
      {int page = 1}) async {
    return TmdbService.discoverMoviesByGenre(genreId, page: page);
  }

  Future<List<SeriesModel>> getSeriesByGenre(int genreId,
      {int page = 1}) async {
    return TmdbService.discoverSeriesByGenre(genreId, page: page);
  }
}
