import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/episode_model.dart';
import '../services/hive_service.dart';

class EpisodeTile extends StatelessWidget {
  final EpisodeModel episode;
  final String seriesImdbId;
  final VoidCallback? onPlay;
  final bool isCurrentEpisode;

  const EpisodeTile({
    super.key,
    required this.episode,
    required this.seriesImdbId,
    this.onPlay,
    this.isCurrentEpisode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isWatched = HiveService.isEpisodeWatched(
        seriesImdbId, episode.seasonNumber, episode.episodeNumber);

    return Container(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm / 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentEpisode
            ? AppColors.accent.withOpacity(0.1)
            : AppColors.card,
        borderRadius: AppRadius.card,
        border: isCurrentEpisode
            ? Border.all(color: AppColors.accent.withOpacity(0.4))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Still image
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: episode.fullStillUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: episode.fullStillUrl,
                        width: 110,
                        height: 65,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(
                          width: 110,
                          height: 65,
                          color: AppColors.surfaceVariant,
                        ),
                        errorWidget: (_, __, ___) => Container(
                          width: 110,
                          height: 65,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.tv, color: AppColors.textMuted),
                        ),
                      )
                    : Container(
                        width: 110,
                        height: 65,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: const Icon(Icons.tv, color: AppColors.textMuted),
                      ),
              ),
              if (isWatched)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 10),
                  ),
                ),
              // Play button overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPlay,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: const Center(
                        child: Icon(Icons.play_circle_fill_rounded,
                            color: Colors.white70, size: 28),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Episode info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      episode.code,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (episode.runtimeFormatted.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        episode.runtimeFormatted,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  episode.name,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (episode.overview != null &&
                    episode.overview!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    episode.overview!,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
