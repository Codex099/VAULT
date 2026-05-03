import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../theme/app_theme.dart';
import '../services/hive_service.dart';
import '../providers/progress_provider.dart';
import '../providers/favorites_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late var _settings = HiveService.getSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            _buildQuickStats(),
            _buildSection('PRÉFÉRENCES', [
              _buildSubtitleTile(),
              _buildSwitchTile(
                icon: Icons.play_circle_outline_rounded,
                title: 'Lecture automatique',
                subtitle: 'Épisode suivant automatique',
                value: _settings.autoPlay,
                onChanged: (v) async {
                  setState(() => _settings.autoPlay = v);
                  await HiveService.saveSettings(_settings);
                },
              ),
            ]),
            _buildSection('SÉCURITÉ & DONNÉES', [
              _buildSwitchTile(
                icon: Icons.history_rounded,
                title: 'Sauvegarder l\'historique',
                subtitle: 'Enregistrer votre activité',
                value: _settings.saveHistory,
                onChanged: (v) async {
                  setState(() => _settings.saveHistory = v);
                  await HiveService.saveSettings(_settings);
                },
              ),
              _buildActionTile(
                icon: Icons.delete_sweep_rounded,
                title: 'Effacer l\'historique',
                color: AppColors.accent,
                onTap: () => _confirmClearHistory(context),
              ),
            ]),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accent, Colors.transparent],
                stops: [0, 0.8],
              ),
            ),
          ),
          // User Info
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.person_rounded, size: 50, color: Colors.white),
                  ),
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                const SizedBox(height: 16),
                const Text(
                  'UTILISATEUR VΛULT',
                  style: TextStyle(
                    fontFamily: 'Bebas Neue',
                    fontSize: 28,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const Text(
                  'Nonihay',
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Consumer2<ProgressProvider, FavoritesProvider>(
      builder: (context, pp, fp, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _statItem('FAVORIS', fp.favorites.length.toString()),
              const SizedBox(width: 12),
              _statItem('REGARDÉ', pp.history.length.toString()),
            ],
          ),
        ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms);
      },
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
          child: Text(
            title,
            style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.accent,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: color ?? Colors.white70),
      title: Text(title, style: TextStyle(color: color ?? Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24),
      onTap: onTap,
    );
  }



  Widget _buildSubtitleTile() {
    const subtitles = {'ar': 'Arabe (AR)', 'en': 'Anglais (EN)', 'off': 'Désactivés'};
    return _buildActionTile(
      icon: Icons.subtitles_outlined,
      title: 'Sous-titres par défaut',
      subtitle: subtitles[_settings.subtitleLanguage] ?? 'Arabe',
      onTap: () => _showPicker('Sous-titres', subtitles, _settings.subtitleLanguage, (v) {
        setState(() => _settings.subtitleLanguage = v);
        HiveService.saveSettings(_settings);
      }),
    );
  }



  void _showPicker(String title, Map<String, String> options, String current, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text(title.toUpperCase(), style: const TextStyle(fontFamily: 'Bebas Neue', fontSize: 20, letterSpacing: 1)),
          const SizedBox(height: 16),
          ...options.entries.map((e) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 32),
                title: Text(e.value, style: TextStyle(color: current == e.key ? AppColors.accent : Colors.white70, fontWeight: FontWeight.bold)),
                trailing: current == e.key ? const Icon(Icons.check_circle_rounded, color: AppColors.accent) : null,
                onTap: () {
                  onSelect(e.key);
                  Navigator.pop(context);
                },
              )),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Tout effacer ?', style: TextStyle(fontFamily: 'Bebas Neue', fontSize: 24)),
          content: const Text('Voulez-vous supprimer tout votre historique VΛULT ?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('ANNULER', style: TextStyle(color: Colors.white38))),
            ElevatedButton(
              onPressed: () {
                context.read<ProgressProvider>().clearHistory();
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('EFFACER'),
            ),
          ],
        ),
      ),
    );
  }


}
