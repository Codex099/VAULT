import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../models/series_model.dart';
import '../models/episode_model.dart';
import '../models/movie_model.dart';
import '../models/progress_model.dart';
import '../providers/favorites_provider.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/section_header.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/cast_card.dart';
import '../widgets/rating_widget.dart';
import '../widgets/genre_chip.dart';
import '../widgets/episode_tile.dart';

class SeriesDetailScreen extends StatefulWidget {
  final String tmdbId;
  const SeriesDetailScreen({super.key, required this.tmdbId});

  @override
  State<SeriesDetailScreen> createState() => _SeriesDetailScreenState();
}

class _SeriesDetailScreenState extends State<SeriesDetailScreen> {
  SeriesModel? _series;
  SeasonDetail? _currentSeason;
  bool _loading = true;
  bool _loadingSeason = false;
  bool _expanded = false;
  int _selectedSeason = 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final series = await TmdbService.getSeriesDetails(int.parse(widget.tmdbId));
      if (mounted) {
        setState(() { _series = series; _loading = false; });
        final firstSeason = series.seasons.where((s) => s.seasonNumber > 0).firstOrNull;
        if (firstSeason != null) {
          _selectedSeason = firstSeason.seasonNumber;
          _loadSeason(firstSeason.seasonNumber);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSeason(int seasonNumber) async {
    if (_loadingSeason) return;
    setState(() => _loadingSeason = true);
    try {
      final season = await TmdbService.getSeasonDetails(int.parse(widget.tmdbId), seasonNumber);
      if (mounted) setState(() { _currentSeason = season; _loadingSeason = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingSeason = false);
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
            : _series == null
                ? const Center(child: Text('Série introuvable', style: TextStyle(color: Colors.white)))
                : _buildDetail(),
      ),
    );
  }

  Widget _buildDetail() {
    final series = _series!;
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverAppBar(series),
        SliverToBoxAdapter(
          child: _buildBody(series).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1, end: 0),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(SeriesModel series) {
    return SliverAppBar(
      expandedHeight: 450,
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
          onPressed: () => Share.share(
            'Regarde ${series.name} sur VΛULT!\nhttps://www.themoviedb.org/tv/${series.tmdbId}',
          ),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            series.fullBackdropUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: series.fullBackdropUrl, fit: BoxFit.cover)
                : Container(color: AppColors.surface),
            // Immersive Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.6, 0.9, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    AppColors.background.withOpacity(0.8),
                    AppColors.background,
                  ],
                ),
              ),
            ),
            // Title Overlay
            Positioned(
              bottom: 40,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Text(
                    series.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 32,
                      shadows: [const Shadow(color: Colors.black87, blurRadius: 20)],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    series.genres.map((g) => g.name).join('  •  ').toUpperCase(),
                    style: const TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(SeriesModel series) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          // Actions Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _playEpisode(series, _selectedSeason, 1),
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('REGARDER'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _buildFavoriteButton(series),
            ],
          ),
          const SizedBox(height: 32),
          // Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _infoItem(series.voteAverage.toStringAsFixed(1), 'RATING', color: AppColors.accent),
              _infoItem(series.year, 'YEAR'),
              _infoItem('${series.numberOfSeasons} SEASONS', 'CONTENT'),
            ],
          ),
          const SizedBox(height: 32),
          // Synopsis
          Text(
            'SYNOPSIS',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          if (series.overview != null)
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Text(
                series.overview!,
                maxLines: _expanded ? null : 4,
                overflow: _expanded ? null : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: Colors.white70,
                ),
              ),
            ),
          const SizedBox(height: 32),
          // Cast
          if (series.cast.isNotEmpty) ...[
            const SectionHeader(title: 'Distribution'),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: series.cast.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) => CastCard(
                  actor: series.cast[i],
                  onTap: () => context.push('/actor/${series.cast[i].id}'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          // Episodes Header
          Text(
            'ÉPISODES',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildSeasonSelector(series),
          const SizedBox(height: 24),
          _buildEpisodeList(series),
          const SizedBox(height: 32),
          // Similar
          if (series.similar.isNotEmpty) ...[
            const SectionHeader(title: 'Recommandations'),
            const SizedBox(height: 16),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: series.similar.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) {
                  final s = series.similar[i];
                  return MovieCard(
                    title: s.name,
                    posterUrl: s.fullPosterUrl,
                    rating: s.voteAverage,
                    onTap: () => context.push('/series/${s.tmdbId}'),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildSeasonSelector(SeriesModel series) {
    final realSeasons = series.seasons.where((s) => s.seasonNumber > 0).toList();
    if (realSeasons.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: realSeasons.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final season = realSeasons[i];
          final isSelected = season.seasonNumber == _selectedSeason;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedSeason = season.seasonNumber);
              _loadSeason(season.seasonNumber);
            },
            child: AnimatedContainer(
              duration: AppDurations.fast,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected ? AppColors.accent : Colors.white12,
                  width: 1,
                ),
              ),
              child: Text(
                'SAISON ${season.seasonNumber}',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEpisodeList(SeriesModel series) {
    if (_loadingSeason) {
      return Column(
        children: List.generate(3, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerCard(width: double.infinity, height: 100),
        )),
      );
    }

    final episodes = _currentSeason?.episodes ?? [];
    if (episodes.isEmpty) {
      return const Center(child: Text('Aucun épisode disponible', style: TextStyle(color: Colors.white38)));
    }

    return Column(
      children: episodes.map((ep) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: EpisodeTile(
          episode: ep,
          seriesImdbId: series.imdbId ?? series.tmdbId.toString(),
          onPlay: () => _playEpisode(series, ep.seasonNumber, ep.episodeNumber),
        ),
      )).toList(),
    );
  }

  Widget _buildFavoriteButton(SeriesModel series) {
    return Consumer<FavoritesProvider>(
      builder: (context, fp, _) {
        final imdbId = series.imdbId ?? series.tmdbId.toString();
        final isFav = fp.isFavorite(imdbId);
        return InkWell(
          onTap: () {
            fp.toggleFavorite(FavoriteItem(
              imdbId: imdbId,
              title: series.name,
              posterUrl: series.fullPosterUrl,
              type: 'series',
              rating: series.voteAverage,
              year: series.year,
              genres: series.genres.map((g) => g.name).toList(),
              addedDate: DateTime.now(),
              tmdbId: series.tmdbId.toString(),
            ));
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.button,
              border: Border.all(color: isFav ? AppColors.accent : Colors.white12),
            ),
            child: Icon(
              isFav ? Icons.bookmark_added_rounded : Icons.bookmark_add_outlined,
              color: isFav ? AppColors.accent : Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(String value, String label, {Color? color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.bebasNeue().fontFamily,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _playEpisode(SeriesModel series, int season, int episode) {
    final imdbId = series.imdbId ?? series.tmdbId.toString();
    context.push('/player/$imdbId', extra: {
      'type': 'series',
      'tmdbId': series.tmdbId.toString(),
      'title': series.name,
      'season': season,
      'episode': episode,
      'posterUrl': series.fullPosterUrl,
    });
  }
}
