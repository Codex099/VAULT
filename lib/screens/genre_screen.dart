import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/movie_model.dart';
import '../models/series_model.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_card.dart';

class GenreScreen extends StatefulWidget {
  final String genreId;
  final String? genreName;
  const GenreScreen({super.key, required this.genreId, this.genreName});

  @override
  State<GenreScreen> createState() => _GenreScreenState();
}

class _GenreScreenState extends State<GenreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MovieModel> _movies = [];
  List<SeriesModel> _series = [];
  bool _loadingMovies = true;
  bool _loadingSeries = true;

  bool get _isSpecial => ['trending', 'top_rated', 'movies', 'series']
      .contains(widget.genreId);

  String get _title {
    switch (widget.genreId) {
      case 'trending': return '🔥 Tendances';
      case 'top_rated': return '⭐ Mieux notés';
      case 'movies': return 'Films populaires';
      case 'series': return 'Séries populaires';
      default: return widget.genreName ?? 'Catalogue';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  int _mapMovieGenreToTvGenre(int movieId) {
    switch (movieId) {
      case 28: return 10759; // Action -> Action & Adventure
      case 12: return 10759; // Adventure -> Action & Adventure
      case 14: return 10765; // Fantasy -> Sci-Fi & Fantasy
      case 878: return 10765; // Sci-Fi -> Sci-Fi & Fantasy
      case 10752: return 10768; // War -> War & Politics
      default: return movieId; // Others like Animation(16), Comedy(35), Drama(18) have same IDs
    }
  }

  Future<void> _load() async {
    try {
      if (_isSpecial) {
        List<MovieModel> movies = [];
        List<SeriesModel> series = [];
        switch (widget.genreId) {
          case 'trending': movies = await TmdbService.getTrendingMovies(); break;
          case 'top_rated':
            movies = await TmdbService.getTopRatedMovies();
            series = await TmdbService.getTopRatedSeries();
            break;
          case 'movies': movies = await TmdbService.getPopularMovies(); break;
          case 'series': series = await TmdbService.getPopularSeries(); break;
        }
        if (mounted) setState(() {
          _movies = movies; _series = series;
          _loadingMovies = false; _loadingSeries = false;
        });
      } else {
        final id = int.tryParse(widget.genreId);
        if (id == null) return;
        
        final tvGenreId = _mapMovieGenreToTvGenre(id);
        
        final results = await Future.wait([
          TmdbService.discoverMoviesByGenre(id),
          TmdbService.discoverSeriesByGenre(tvGenreId),
        ]);
        if (mounted) setState(() {
          _movies = results[0] as List<MovieModel>;
          _series = results[1] as List<SeriesModel>;
          _loadingMovies = false;
          _loadingSeries = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _loadingMovies = false; _loadingSeries = false; });
    }
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: AppColors.accent,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [Tab(text: 'Films'), Tab(text: 'Séries')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGrid(_movies, _loadingMovies, isMovie: true),
          _buildGrid(_series, _loadingSeries, isMovie: false),
        ],
      ),
    );
  }

  Widget _buildGrid(List items, bool loading, {required bool isMovie}) {
    if (loading && items.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 0.5,
          crossAxisSpacing: 8, mainAxisSpacing: 8,
        ),
        itemCount: 9,
        itemBuilder: (_, __) => const ShimmerCard(width: double.infinity, height: 180),
      );
    }
    if (items.isEmpty) {
      return const Center(child: Text('Aucun contenu', style: TextStyle(color: AppColors.textMuted)));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 0.5,
        crossAxisSpacing: 8, mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final title = isMovie ? (item as MovieModel).title : (item as SeriesModel).name;
        final poster = isMovie ? (item as MovieModel).fullPosterUrl : (item as SeriesModel).fullPosterUrl;
        final rating = isMovie ? (item as MovieModel).voteAverage : (item as SeriesModel).voteAverage;
        final id = isMovie ? (item as MovieModel).tmdbId : (item as SeriesModel).tmdbId;
        return MovieCard(
          title: title, posterUrl: poster, rating: rating,
          size: MovieCardSize.small,
          onTap: () => context.push(isMovie ? '/movie/$id' : '/series/$id'),
        );
      },
    );
  }
}
