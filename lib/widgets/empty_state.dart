import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textMuted, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyFavorites extends StatelessWidget {
  const EmptyFavorites({super.key});
  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'Aucun favori',
        message: 'Ajoutez des films et séries à votre liste en appuyant sur le cœur.',
      );
}

class EmptyHistory extends StatelessWidget {
  const EmptyHistory({super.key});
  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.history_rounded,
        title: 'Historique vide',
        message: 'Vos films et séries regardés apparaîtront ici.',
      );
}

class EmptyContinueWatching extends StatelessWidget {
  const EmptyContinueWatching({super.key});
  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.play_circle_outline_rounded,
        title: 'Rien à reprendre',
        message: 'Commencez à regarder et reprenez là où vous vous êtes arrêté.',
      );
}

class EmptySearch extends StatelessWidget {
  const EmptySearch({super.key});
  @override
  Widget build(BuildContext context) => const EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        message: 'Essayez avec d\'autres mots-clés.',
      );
}
