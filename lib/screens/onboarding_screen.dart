import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'BIENVENUE DANS LE VΛULT',
      subtitle: 'Une expérience cinématographique ultime, conçue pour les passionnés.',
      icon: Icons.movie_filter_rounded,
    ),
    OnboardingData(
      title: 'IMMERSION TOTALE',
      subtitle: 'Contrôles intuitifs, design épuré et fluidité exceptionnelle.',
      icon: Icons.touch_app_rounded,
    ),
    OnboardingData(
      title: 'VOTRE COLLECTION',
      subtitle: 'Sauvegardez vos favoris et reprenez la lecture où vous vous êtes arrêté.',
      icon: Icons.bookmark_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Gradient
          AnimatedContainer(
            duration: 800.ms,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  AppColors.accent.withOpacity(0.15),
                  AppColors.background,
                ],
              ),
            ),
          ),
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (context, i) => _buildPage(_pages[i]),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: Icon(data.icon, size: 80, color: AppColors.accent),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut).rotate(begin: -0.1, end: 0),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Bebas Neue',
              fontSize: 40,
              color: Colors.white,
              letterSpacing: 2,
              height: 1,
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 24),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 16,
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Positioned(
      bottom: 60,
      left: 40,
      right: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dots
          Row(
            children: List.generate(_pages.length, (i) => _buildDot(i)),
          ),
          // Button
          GestureDetector(
            onTap: () {
              if (_currentPage < _pages.length - 1) {
                _controller.nextPage(duration: 400.ms, curve: Curves.easeInOut);
              } else {
                context.go('/home');
              }
            },
            child: AnimatedContainer(
              duration: 300.ms,
              padding: EdgeInsets.symmetric(horizontal: _currentPage == _pages.length - 1 ? 32 : 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    _currentPage == _pages.length - 1 ? 'COMMENCER' : 'SUIVANT',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                  ),
                  if (_currentPage < _pages.length - 1) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: 300.ms,
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent : Colors.white24,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  OnboardingData({required this.title, required this.subtitle, required this.icon});
}
