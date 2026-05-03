import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../models/movie_model.dart';

class HeroBanner extends StatefulWidget {
  final List<MovieModel> movies;
  final void Function(MovieModel)? onWatch;
  final void Function(MovieModel)? onAddList;

  const HeroBanner({
    super.key,
    required this.movies,
    this.onWatch,
    this.onAddList,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;
      final nextIndex = (_currentIndex + 1) % widget.movies.length;
      _pageController.animateToPage(
        nextIndex,
        duration: AppDurations.slow,
        curve: AppDurations.cubicBezier,
      );
      _startAutoPlay();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox(height: 500);

    return SizedBox(
      height: 580,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _BannerPage(
                movie: movie,
                onWatch: () => widget.onWatch?.call(movie),
                onAddList: () => widget.onAddList?.call(movie),
              );
            },
          ),
          // Page Indicator
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.movies.length.clamp(0, 6),
                (index) => AnimatedContainer(
                  duration: AppDurations.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == index ? AppColors.accent : Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BannerPage extends StatelessWidget {
  final MovieModel movie;
  final VoidCallback? onWatch;
  final VoidCallback? onAddList;

  const _BannerPage({
    required this.movie,
    this.onWatch,
    this.onAddList,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Backdrop Image
        movie.fullBackdropUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: movie.fullBackdropUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              )
            : Container(color: AppColors.surface),

        // Deep cinematic gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 0.8, 1.0],
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                AppColors.background,
              ],
            ),
          ),
        ),

        // Content
        Positioned(
          bottom: 60,
          left: 24,
          right: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display Title
              Text(
                movie.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  height: 1.0,
                  shadows: [
                    const Shadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 5)),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Meta Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (movie.voteAverage > 0) ...[
                    const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      movie.voteAverage.toStringAsFixed(1),
                      style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    movie.year,
                    style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                  if (movie.genres.isNotEmpty) ...[
                    const SizedBox(width: 12),
                    const Text('·', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(width: 12),
                    Text(
                      movie.genres.first.name,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              // CTA Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onWatch,
                      icon: const Icon(Icons.play_arrow_rounded, size: 24),
                      label: const Text('REGARDER'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: AppRadius.button,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: OutlinedButton.icon(
                          onPressed: onAddList,
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text('MA LISTE'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
