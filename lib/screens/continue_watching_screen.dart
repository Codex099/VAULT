import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../models/progress_model.dart';
import '../widgets/progress_card.dart';
import '../widgets/empty_state.dart';
import '../services/hive_service.dart';

class ContinueWatchingScreen extends StatefulWidget {
  const ContinueWatchingScreen({super.key});

  @override
  State<ContinueWatchingScreen> createState() => _ContinueWatchingScreenState();
}

class _ContinueWatchingScreenState extends State<ContinueWatchingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Continuer à regarder')),
      body: Consumer<ProgressProvider>(
        builder: (context, pp, _) {
          if (pp.continueWatching.isEmpty) return const EmptyContinueWatching();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pp.continueWatching.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final p = pp.continueWatching[i];
              return _ContinueWatchingTile(
                progress: p,
                onResume: () => _resume(p),
                onRemove: () => pp.removeProgress(p.imdbId),
              );
            },
          );
        },
      ),
    );
  }

  void _resume(WatchProgress p) {
    if (p.type == 'movie') {
      context.go('/player/${p.imdbId}', extra: {
        'type': 'movie',
        'tmdbId': p.tmdbId,
        'title': p.title,
        'posterUrl': p.posterUrl,
        'backdropUrl': p.backdropUrl,
      });
    } else {
      final sp = HiveService.getSeriesProgress(p.imdbId);
      context.go('/player/${p.imdbId}', extra: {
        'type': 'series',
        'tmdbId': p.tmdbId,
        'title': p.title,
        'season': sp?.lastSeason ?? 1,
        'episode': sp?.lastEpisode ?? 1,
        'posterUrl': p.posterUrl,
        'backdropUrl': p.backdropUrl,
      });
    }
  }
}

class _ContinueWatchingTile extends StatelessWidget {
  final WatchProgress progress;
  final VoidCallback onResume;
  final VoidCallback onRemove;

  const _ContinueWatchingTile({
    required this.progress,
    required this.onResume,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.progressPercent * 100).round();
    final remaining = progress.totalDurationSeconds > 0
        ? ((progress.totalDurationSeconds - progress.lastPositionSeconds) / 60).round()
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          // Poster
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              bottomLeft: Radius.circular(AppRadius.lg),
            ),
            child: Stack(
              children: [
                progress.posterUrl.isNotEmpty
                    ? Image.network(
                        progress.posterUrl,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 80,
                          height: 120,
                          color: AppColors.surfaceVariant,
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 120,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.movie, color: AppColors.textMuted),
                      ),
                // Progress bar on bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress.progressPercent.clamp(0.0, 1.0),
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    progress.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress.type == 'series'
                        ? '${pct}% regardé'
                        : remaining > 0
                            ? '${remaining} min restantes'
                            : '${pct}% regardé',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          // Actions
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle_fill_rounded,
                    color: AppColors.accent, size: 36),
                onPressed: onResume,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
