import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../models/movie_model.dart';
import '../models/progress_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/progress_provider.dart';
import '../services/tmdb_service.dart';
import '../services/subtitle_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/cast_card.dart';
import '../widgets/rating_widget.dart';
import '../widgets/genre_chip.dart';

class MovieDetailScreen extends StatefulWidget {
  final String tmdbId;
  const MovieDetailScreen({super.key, required this.tmdbId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  MovieModel? _movie;
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final movie = await TmdbService.getMovieDetails(int.parse(widget.tmdbId));
      if (mounted) setState(() { _movie = movie; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : _movie == null
                ? const Center(child: Text('Film introuvable', style: TextStyle(color: Colors.white)))
                : _buildDetail(),
      ),
    );
  }

  Widget _buildDetail() {
    final movie = _movie!;
    final genreColor = AppColors.genreColors[movie.genres.firstOrNull?.name] ?? AppColors.accent;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(movie, genreColor),
        SliverToBoxAdapter(
          child: _buildBody(movie, genreColor).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(MovieModel movie, Color genreColor) {
    return SliverAppBar(
      expandedHeight: 500,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black26,
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black26,
                child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
              ),
            ),
          ),
          onPressed: () => Share.share('Regarde ${movie.title} sur VΛULT!'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: movie.fullBackdropUrl,
              fit: BoxFit.cover,
            ),
            // Immersive Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0, 0.4, 0.8, 1],
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Title & Info
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    movie.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      color: Colors.white,
                      fontSize: 42,
                      height: 0.9,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _badge(movie.year),
                      const SizedBox(width: 12),
                      _badge(movie.runtimeFormatted),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildBody(MovieModel movie, Color genreColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActionButtons(movie, genreColor),
          const SizedBox(height: 32),
          // Genres
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genres.map((g) => GenreChip(label: g.name)).toList(),
          ),
          const SizedBox(height: 32),
          // Synopsis
          const Text('SYNOPSIS', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 20, letterSpacing: 1.2, color: Colors.white)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Text(
              movie.overview ?? '',
              maxLines: _expanded ? null : 4,
              overflow: _expanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
            ),
          ),
          const SizedBox(height: 32),
          // Cast
          if (movie.cast.isNotEmpty) ...[
            const SectionHeader(title: 'DISTRIBUTION'),
            const SizedBox(height: 16),
            SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: movie.cast.length,
                itemBuilder: (_, i) => CastCard(
                  actor: movie.cast[i],
                  onTap: () => context.push('/actor/${movie.cast[i].id}'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          // Similar
          if (movie.similar.isNotEmpty) ...[
            const SectionHeader(title: 'VOUS POURRIEZ AIMER'),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: movie.similar.length,
                itemBuilder: (_, i) {
                  final m = movie.similar[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: MovieCard(
                      title: m.title,
                      posterUrl: m.fullPosterUrl,
                      rating: m.voteAverage,
                      onTap: () => context.push('/movie/${m.tmdbId}'),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildActionButtons(MovieModel movie, Color genreColor) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _startWatching(movie),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                  SizedBox(width: 8),
                  Text('REGARDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildFavoriteButton(movie),
      ],
    );
  }

  Widget _buildFavoriteButton(MovieModel movie) {
    return Consumer<FavoritesProvider>(
      builder: (context, fp, _) {
        final imdbId = movie.imdbId ?? movie.tmdbId.toString();
        final isFav = fp.isFavorite(imdbId);
        return GestureDetector(
          onTap: () {
            fp.toggleFavorite(FavoriteItem(
              imdbId: imdbId,
              title: movie.title,
              posterUrl: movie.fullPosterUrl,
              type: 'movie',
              rating: movie.voteAverage,
              year: movie.year,
              genres: movie.genres.map((g) => g.name).toList(),
              addedDate: DateTime.now(),
              tmdbId: movie.tmdbId.toString(),
            ));
          },
          child: Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isFav ? AppColors.accent : Colors.white12),
            ),
            child: Icon(
              isFav ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: isFav ? AppColors.accent : Colors.white,
            ),
          ),
        );
      },
    );
  }

  void _startWatching(MovieModel movie) {
    final imdbId = movie.imdbId ?? movie.tmdbId.toString();
    context.push('/player/$imdbId', extra: {
      'type': 'movie',
      'tmdbId': movie.tmdbId.toString(),
      'title': movie.title,
      'posterUrl': movie.fullPosterUrl,
    });
  }
}
