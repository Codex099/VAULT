import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../providers/movie_provider.dart';
import '../services/hive_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_card.dart';
import '../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _filter = 'all';
  List<String> _recentSearches = [];

  final _filters = [
    ('all', 'TOUT'),
    ('movie', 'FILMS'),
    ('tv', 'SÉRIES'),
    ('person', 'ACTEURS'),
  ];

  @override
  void initState() {
    super.initState();
    _recentSearches = HiveService.getRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      context.read<MovieProvider>().clearSearch();
      setState(() {});
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => context.read<MovieProvider>().search(query),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: Consumer<MovieProvider>(
                builder: (context, mp, _) {
                  if (_controller.text.isEmpty) return _buildEmptyState();
                  if (mp.isSearching) return _buildLoading();
                  if (mp.searchResults.isEmpty) return const EmptySearch();
                  return _buildResults(mp.searchResults);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text('RECHERCHE', style: Theme.of(context).textTheme.displaySmall),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Films, séries, acteurs...',
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    icon: const Icon(Icons.search_rounded, color: AppColors.accent),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                            onPressed: () {
                              _controller.clear();
                              context.read<MovieProvider>().clearSearch();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFilters(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_recentSearches.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RÉCENT',
                    style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  TextButton(
                    onPressed: () async {
                      await HiveService.clearRecentSearches();
                      setState(() => _recentSearches = []);
                    },
                    child: const Text('EFFACER', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            ...(_recentSearches.reversed.take(6).map(
              (s) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Icons.history_rounded, color: Colors.white24, size: 20),
                title: Text(s, style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.north_west_rounded, color: Colors.white24, size: 16),
                onTap: () {
                  _controller.text = s;
                  _onSearchChanged(s);
                },
              ),
            )),
          ],
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Icon(Icons.search_rounded, size: 64, color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 16),
                const Text('Explorez le VΛULT', style: TextStyle(color: Colors.white24, fontSize: 14)),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _filters.map((f) {
          final selected = _filter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.accent : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: selected ? AppColors.accent : Colors.white12),
                ),
                child: Text(
                  f.$2,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerCard(width: double.infinity),
    );
  }

  Widget _buildResults(List<dynamic> results) {
    final filtered = _filter == 'all'
        ? results
        : results
            .where((r) => (r as Map)['media_type'] == _filter)
            .toList();

    if (filtered.isEmpty) return const EmptySearch();

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, i) {
        final item = filtered[i] as Map<String, dynamic>;
        final type = item['media_type'] as String? ?? 'movie';
        final title = (item['title'] ?? item['name'] ?? '') as String;
        final poster = item['poster_path'] as String?;
        final rating = (item['vote_average'] as num?)?.toDouble() ?? 0.0;
        final id = item['id'] as int;

        return MovieCard(
          title: title,
          posterUrl: poster != null ? 'https://image.tmdb.org/t/p/w500$poster' : '',
          rating: rating,
          onTap: () {
            HiveService.addRecentSearch(_controller.text);
            if (type == 'movie') {
              context.push('/movie/$id');
            } else if (type == 'tv') {
              context.push('/series/$id');
            } else if (type == 'person') {
              context.push('/actor/$id');
            }
          },
        ).animate().fadeIn(duration: 400.ms, delay: (i % 6 * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
