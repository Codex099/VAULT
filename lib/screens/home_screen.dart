import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../providers/movie_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/movie_model.dart';
import '../models/progress_model.dart';
import '../widgets/hero_banner.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_card.dart';
import '../services/hive_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mp = context.read<MovieProvider>();
      if (mp.popular.isEmpty) mp.loadHomeData();
      context.read<ProgressProvider>().load();
      context.read<FavoritesProvider>().loadFavorites();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
    
    final pos = _scrollController.position;
    if (pos.pixels > pos.maxScrollExtent * 0.8) {
      context.read<MovieProvider>().loadMorePopular();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _isScrolled ? 18 : 0,
            sigmaY: _isScrolled ? 18 : 0,
          ),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            color: _isScrolled 
              ? Colors.black.withOpacity(0.7) 
              : Colors.transparent,
          ),
        ),
      ),
      title: Text(
        'VΛULT',
        style: GoogleFonts.bebasNeue(
          color: AppColors.accent,
          fontSize: 32,
          letterSpacing: 4.0,
          fontWeight: FontWeight.bold,
        ),
      ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.2, end: 0),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 28),
          onPressed: () => context.push('/search'),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => context.push('/settings'),
          child: Container(
            margin: const EdgeInsets.only(right: 24),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12, width: 1.5),
              image: const DecorationImage(
                image: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Vault'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Consumer3<MovieProvider, ProgressProvider, FavoritesProvider>(
      builder: (context, mp, pp, fp, _) {
        if (mp.isLoading) return _buildSkeleton();
        if (mp.error != null) return _buildError(mp.error!);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroBanner(
              movies: mp.trending.take(7).toList(),
              onWatch: (movie) => _navigateToWatch(movie),
              onAddList: (movie) => _addToList(movie, fp),
            ),

            const SizedBox(height: 20),

            ...[
              if (pp.hasContinueWatching) ...[
                const SectionHeader(title: 'Reprendre la lecture'),
                const SizedBox(height: 16),
                _buildContinueWatchingList(pp),
                const SizedBox(height: 32),
              ],

              SectionHeader(
                title: 'Tendances Mondiales',
                onSeeAll: () => context.push('/genre/trending'),
              ),
              const SizedBox(height: 16),
              _buildHorizontalMovieList(mp.trending, numbered: true),
              const SizedBox(height: 32),

              SectionHeader(
                title: 'Films à ne pas manquer',
                onSeeAll: () => context.push('/genre/movies'),
              ),
              const SizedBox(height: 16),
              _buildHorizontalMovieList(mp.popular),
              const SizedBox(height: 32),

              SectionHeader(
                title: 'Séries du moment',
                onSeeAll: () => context.push('/genre/series'),
              ),
              const SizedBox(height: 16),
              _buildHorizontalSeriesList(mp.popularSeries),
              const SizedBox(height: 32),

              const SizedBox(height: 60),
            ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
          ],
        );
      },
    );
  }

  Widget _buildContinueWatchingList(ProgressProvider pp) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: pp.continueWatching.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = pp.continueWatching[i];
          return SizedBox(
            width: 200,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.card,
                  child: CachedNetworkImage(
                    imageUrl: p.posterUrl,
                    width: 200,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: 0, right: 0, top: 0,
                  height: 110,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.card,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 28,
                  left: 10,
                  right: 10,
                  child: Text(
                    p.title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 10,
                  right: 10,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: p.progressPercent.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0, right: 0, top: 0, height: 110,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: AppRadius.card,
                      onTap: () => _resumeWatching(p),
                      child: Center(
                        child: Icon(Icons.play_circle_fill_rounded, color: Colors.white.withOpacity(0.85), size: 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<MovieModel> movies, {bool numbered = false}) {
    if (movies.isEmpty) return const ShimmerList();
    return SizedBox(
      height: numbered ? 280 : 250,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.fromLTRB(numbered ? 32 : 24, 0, 24, numbered ? 20 : 0),
        itemCount: movies.length,
        separatorBuilder: (_, __) => SizedBox(width: numbered ? 24 : 16),
        itemBuilder: (_, i) {
          final movie = movies[i];
          return Stack(
            clipBehavior: Clip.none,
            children: [
              MovieCard(
                title: movie.title,
                posterUrl: movie.fullPosterUrl,
                rating: movie.voteAverage,
                year: movie.year,
                label: i < 3 ? 'TOP ${i+1}' : null,
                onTap: () => context.push('/movie/${movie.tmdbId}'),
              ),
              if (numbered)
                Positioned(
                  bottom: -18,
                  left: -18,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.w900,
                      fontFamily: GoogleFonts.bebasNeue().fontFamily,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = AppColors.accent.withOpacity(0.5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHorizontalSeriesList(List series) {
    if (series.isEmpty) return const ShimmerList();
    return SizedBox(
      height: 250,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: series.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, i) {
          final s = series[i];
          return MovieCard(
            title: s.name,
            posterUrl: s.fullPosterUrl,
            rating: s.voteAverage,
            year: s.year,
            onTap: () => context.push('/series/${s.tmdbId}'),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBanner(),
        const SizedBox(height: 24),
        const ShimmerList(),
        const SizedBox(height: 28),
        const ShimmerList(),
      ],
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.accent, size: 64),
          const SizedBox(height: 16),
          Text('Erreur de chargement', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<MovieProvider>().loadHomeData(),
            child: const Text('RÉESSAYER'),
          ),
        ],
      ),
    );
  }

  void _navigateToWatch(MovieModel movie) {
    context.push('/movie/${movie.tmdbId}');
  }

  void _addToList(MovieModel movie, FavoritesProvider fp) {
    final item = FavoriteItem(
      imdbId: movie.imdbId ?? movie.tmdbId.toString(),
      title: movie.title,
      posterUrl: movie.fullPosterUrl,
      type: 'movie',
      rating: movie.voteAverage,
      year: movie.year,
      genres: movie.genres.map((g) => g.name).toList(),
      addedDate: DateTime.now(),
      tmdbId: movie.tmdbId.toString(),
    );
    fp.toggleFavorite(item);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fp.isFavorite(item.imdbId)
            ? '${movie.title} ajouté à VAULT'
            : '${movie.title} retiré de VAULT'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  void _resumeWatching(WatchProgress p) {
    if (p.type == 'movie') {
      context.push('/player/${p.imdbId}', extra: {'type': 'movie', 'tmdbId': p.tmdbId, 'title': p.title});
    } else {
      final sp = HiveService.getSeriesProgress(p.imdbId);
      context.push('/player/${p.imdbId}', extra: {
        'type': 'series',
        'tmdbId': p.tmdbId,
        'title': p.title,
        'season': sp?.lastSeason ?? 1,
        'episode': sp?.lastEpisode ?? 1,
      });
    }
  }
}
