import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/progress_model.dart';

class ProgressCard extends StatelessWidget {
  final WatchProgress progress;
  final VoidCallback? onResume;
  final VoidCallback? onRemove;

  const ProgressCard({
    super.key,
    required this.progress,
    this.onResume,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onResume,
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.card,
                  child: progress.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: progress.posterUrl,
                          width: 150,
                          height: 220,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 150,
                            height: 220,
                            color: AppColors.surfaceVariant,
                          ),
                        )
                      : Container(
                          width: 150,
                          height: 220,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.movie,
                              color: AppColors.textMuted, size: 40),
                        ),
                ),
                // Remove button
                if (onRemove != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                // Play overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.card,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.play_circle_fill_rounded,
                          color: Colors.white70, size: 42),
                    ),
                  ),
                ),
                // Progress bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(AppRadius.lg),
                        bottomRight: Radius.circular(AppRadius.lg),
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.progressPercent.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(AppRadius.lg),
                            bottomRight: Radius.circular(AppRadius.lg),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              progress.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress.progressPercent * 100).round()}% regardé',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
