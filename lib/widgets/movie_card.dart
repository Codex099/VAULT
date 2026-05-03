import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

enum MovieCardSize { small, medium, large }

class MovieCard extends StatefulWidget {
  final String title;
  final String posterUrl;
  final double rating;
  final String? year;
  final VoidCallback? onTap;
  final MovieCardSize size;
  final String? label;
  final double? progress;

  const MovieCard({
    super.key,
    required this.title,
    required this.posterUrl,
    this.rating = 0.0,
    this.year,
    this.onTap,
    this.size = MovieCardSize.medium,
    this.label,
    this.progress,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool _isPressed = false;

  double get _width {
    switch (widget.size) {
      case MovieCardSize.small: return 100;
      case MovieCardSize.medium: return 130;
      case MovieCardSize.large: return 160;
    }
  }

  double get _height => _width * 1.5;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppDurations.fast,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth != double.infinity ? constraints.maxWidth : _width;
            final h = w * 1.5;

            return SizedBox(
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPoster(w, h),
                  const SizedBox(height: 10),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: widget.size == MovieCardSize.small ? 12 : 14,
                  letterSpacing: 0.2,
                ),
              ),
              if (widget.rating > 0) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      widget.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.year != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        widget.year!,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
      ),
      ),
    )
    .animate()
    .fadeIn(duration: AppDurations.normal, curve: AppDurations.cubicBezier)
    .slideY(begin: 0.1, end: 0, duration: AppDurations.normal, curve: AppDurations.cubicBezier);
  }

  Widget _buildPoster(double w, double h) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        boxShadow: [
          if (_isPressed)
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: AppRadius.card,
            child: widget.posterUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: widget.posterUrl,
                    width: w,
                    height: h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _shimmerPlaceholder(w, h),
                    errorWidget: (_, __, ___) => _errorPlaceholder(w, h),
                  )
                : _errorPlaceholder(w, h),
          ),
          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
          ),
          // Progress bar
          if (widget.progress != null && widget.progress! > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 3,
                color: Colors.white.withOpacity(0.2),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.progress!.clamp(0.0, 1.0),
                  child: Container(color: AppColors.accent),
                ),
              ),
            ),
          // Label Badge (NEW/HD)
          if (widget.label != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  widget.label!.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _shimmerPlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: AppColors.shimmerBase,
    );
  }

  Widget _errorPlaceholder(double w, double h) {
    return Container(
      width: w,
      height: h,
      color: AppColors.surface,
      child: const Icon(Icons.movie_filter_rounded, color: AppColors.border, size: 40),
    );
  }
}
