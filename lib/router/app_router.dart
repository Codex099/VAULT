import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/movie_detail_screen.dart';
import '../screens/series_detail_screen.dart';
import '../screens/player_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/history_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/settings_screen.dart'; // Keep for now or remove if confident
import '../screens/continue_watching_screen.dart';
import '../screens/genre_screen.dart';
import '../screens/actor_screen.dart';
import '../theme/app_theme.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),

    // Shell route with bottom navigation
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (_, state) => NoTransitionPage(child: const HomeScreen()),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (_, state) => NoTransitionPage(child: const SearchScreen()),
        ),
        GoRoute(
          path: '/favorites',
          pageBuilder: (_, state) => NoTransitionPage(child: const FavoritesScreen()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder: (_, state) => NoTransitionPage(child: const HistoryScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, state) => NoTransitionPage(child: const ProfileScreen()),
        ),
      ],
    ),

    // Full-screen routes (no bottom nav)
    GoRoute(
      path: '/movie/:tmdbId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => MaterialPage(
        child: MovieDetailScreen(tmdbId: state.pathParameters['tmdbId']!),
      ),
    ),
    GoRoute(
      path: '/series/:tmdbId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => MaterialPage(
        child: SeriesDetailScreen(tmdbId: state.pathParameters['tmdbId']!),
      ),
    ),
    GoRoute(
      path: '/player/:imdbId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => MaterialPage(
        fullscreenDialog: true,
        child: PlayerScreen(
          imdbId: state.pathParameters['imdbId']!,
          extra: (state.extra as Map<String, dynamic>?) ?? {},
        ),
      ),
    ),
    GoRoute(
      path: '/continue',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, __) => const ContinueWatchingScreen(),
    ),
    GoRoute(
      path: '/genre/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => MaterialPage(
        child: GenreScreen(
          genreId: state.pathParameters['id']!,
          genreName: state.uri.queryParameters['name'],
        ),
      ),
    ),
    GoRoute(
      path: '/actor/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (_, state) => MaterialPage(
        child: ActorScreen(actorId: state.pathParameters['id']!),
      ),
    ),
  ],
);

// ─── App Shell (Bottom Navigation) ───────────────────────────────────────────

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/favorites')) return 1;
    if (location.startsWith('/history')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final safeBottom = (bottomPadding + 12).clamp(16.0, 40.0);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Container(
        margin: EdgeInsets.fromLTRB(24, 0, 24, safeBottom),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A).withOpacity(0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: true,
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                elevation: 0,
                backgroundColor: Colors.transparent,
                selectedItemColor: AppColors.accent,
                unselectedItemColor: Colors.white38,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  switch (index) {
                    case 0: context.go('/home'); break;
                    case 1: context.go('/favorites'); break;
                    case 2: context.go('/history'); break;
                    case 3: context.go('/settings'); break;
                  }
                },
                items: [
                  _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'ACCUEIL', currentIndex == 0),
                  _buildNavItem(Icons.bookmark_outline_rounded, Icons.bookmark_rounded, 'MA LISTE', currentIndex == 1),
                  _buildNavItem(Icons.history_rounded, Icons.history_rounded, 'HISTORIQUE', currentIndex == 2),
                  _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 'PROFIL', currentIndex == 3),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, IconData activeIcon, String label, bool isSelected) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Icon(icon, size: 24),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(activeIcon, size: 24, color: AppColors.accent),
        ),
      ),
      label: label,
    );
  }
}
