import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../providers/favorites_provider.dart';
import '../models/progress_model.dart';
import '../widgets/movie_card.dart';
import '../widgets/empty_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
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
              child: Consumer<FavoritesProvider>(
                builder: (context, fp, _) {
                  if (fp.favorites.isEmpty) return const EmptyFavorites();

                  final items = _filter == 'all'
                      ? fp.favorites
                      : _filter == 'movie'
                          ? fp.movies
                          : fp.series;

                  if (items.isEmpty) return const EmptyFavorites();

                  return _buildGrid(items, fp);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MA LISTE', style: Theme.of(context).textTheme.displaySmall),
              _buildSortMenu(),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'TOUT'),
                const SizedBox(width: 12),
                _filterChip('movie', 'FILMS'),
                const SizedBox(width: 12),
                _filterChip('series', 'SÉRIES'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white.withOpacity(0.05),
            child: const Icon(Icons.sort_rounded, color: Colors.white, size: 20),
          ),
        ),
      ),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (val) {
        final fp = context.read<FavoritesProvider>();
        if (val == 'date') fp.sortByDate();
        if (val == 'rating') fp.sortByRating();
        if (val == 'title') fp.sortByTitle();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'date', child: Text('Par Date')),
        const PopupMenuItem(value: 'rating', child: Text('Par Note')),
        const PopupMenuItem(value: 'title', child: Text('Par Titre')),
      ],
    );
  }

  Widget _buildGrid(List<FavoriteItem> items, FavoritesProvider fp) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return GestureDetector(
          onLongPress: () => _confirmRemove(context, fp, item),
          child: MovieCard(
            title: item.title,
            posterUrl: item.posterUrl,
            rating: item.rating,
            year: item.year,
            onTap: () {
              if (item.type == 'movie') {
                context.push('/movie/${item.tmdbId}');
              } else {
                context.push('/series/${item.tmdbId}');
              }
            },
          ).animate().fadeIn(duration: 400.ms, delay: (i % 6 * 50).ms).slideY(begin: 0.1, end: 0),
        );
      },
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: selected ? AppColors.accent : Colors.white12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, FavoritesProvider fp, FavoriteItem item) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Retirer de la liste ?', style: Theme.of(context).textTheme.titleLarge),
          content: Text('Voulez-vous retirer "${item.title}" de votre liste VΛULT ?', 
            style: const TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ANNULER', style: TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                fp.removeFavorite(item.imdbId);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('RETIRER', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
