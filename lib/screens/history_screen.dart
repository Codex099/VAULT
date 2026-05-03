import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../models/progress_model.dart';
import '../widgets/empty_state.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<ProgressProvider>(
                builder: (context, pp, _) {
                  if (pp.history.isEmpty) return const EmptyHistory();

                  final grouped = pp.groupedHistory;
                  final groups = grouped.keys.toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (_, gi) {
                      final group = groups[gi];
                      final items = grouped[group]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              group.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          ...items.asMap().entries.map((entry) {
                            final key = pp.history.indexOf(entry.value);
                            return _HistoryTile(
                              item: entry.value,
                              historyKey: key.toString(),
                              onRemove: () => pp.removeHistoryItem(
                                  '${entry.value.imdbId}_${entry.value.watchedDate.millisecondsSinceEpoch}'),
                              onResume: () => _resume(entry.value),
                            ).animate().fadeIn(duration: 400.ms, delay: (entry.key * 50).ms).slideX(begin: 0.05, end: 0);
                          }),
                          const SizedBox(height: 12),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('HISTORIQUE', style: Theme.of(context).textTheme.displaySmall),
          IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white.withOpacity(0.05),
                  child: const Icon(Icons.delete_sweep_rounded, color: AppColors.accent, size: 20),
                ),
              ),
            ),
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
    );
  }

  void _resume(HistoryItem item) {
    if (item.type == 'movie') {
      context.push('/player/${item.imdbId}', extra: {
        'type': 'movie',
        'tmdbId': item.tmdbId,
        'title': item.title,
        'posterUrl': item.posterUrl,
      });
    } else {
      context.push('/player/${item.imdbId}', extra: {
        'type': 'series',
        'tmdbId': item.tmdbId,
        'title': item.title,
        'season': item.season ?? 1,
        'episode': item.episode ?? 1,
        'posterUrl': item.posterUrl,
      });
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Tout effacer ?', style: Theme.of(context).textTheme.titleLarge),
          content: const Text('Voulez-vous supprimer tout votre historique VΛULT ?', 
            style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ANNULER', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ProgressProvider>().clearHistory();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('EFFACER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final String historyKey;
  final VoidCallback onRemove;
  final VoidCallback onResume;

  const _HistoryTile({
    required this.item,
    required this.historyKey,
    required this.onRemove,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('HH:mm').format(item.watchedDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(historyKey),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: AppColors.accent),
        ),
        onDismissed: (_) => onRemove(),
        child: InkWell(
          onTap: onResume,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: item.posterUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: item.posterUrl,
                          width: 50,
                          height: 75,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 75,
                          color: Colors.white12,
                          child: const Icon(Icons.movie_rounded, color: Colors.white24),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.type == 'series' ? 'S${item.season ?? 1} E${item.episode ?? 1}' : 'FILM',
                              style: const TextStyle(color: AppColors.accent, fontSize: 9, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(dateStr, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.play_circle_fill_rounded, color: Colors.white24, size: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
