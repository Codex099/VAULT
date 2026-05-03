import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../services/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late var _settings = HiveService.getSettings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [
          _sectionTitle('Langue & Région'),
          _buildLanguageTile(),
          _buildSubtitleTile(),
          _divider(),

          _sectionTitle('Lecteur'),
          _buildSwitchTile(
            icon: Icons.play_circle_outline_rounded,
            title: 'Lecture automatique',
            subtitle: 'Lancer automatiquement l\'épisode suivant',
            value: _settings.autoPlay,
            onChanged: (v) async {
              setState(() => _settings.autoPlay = v);
              await HiveService.saveSettings(_settings);
            },
          ),
          _buildSourceTile(),
          _divider(),

          _sectionTitle('Confidentialité'),
          _buildSwitchTile(
            icon: Icons.history_rounded,
            title: 'Sauvegarder l\'historique',
            subtitle: 'Enregistrer les films et séries regardés',
            value: _settings.saveHistory,
            onChanged: (v) async {
              setState(() => _settings.saveHistory = v);
              await HiveService.saveSettings(_settings);
            },
          ),
          _buildActionTile(
            icon: Icons.delete_outline_rounded,
            title: 'Effacer l\'historique',
            subtitle: 'Supprimer tout votre historique de visionnage',
            onTap: () => _confirmClearHistory(context),
          ),
          _divider(),

          _sectionTitle('Données'),
          _buildActionTile(
            icon: Icons.upload_rounded,
            title: 'Exporter les données',
            subtitle: 'Exporter favoris et paramètres en JSON',
            onTap: _exportData,
          ),
          _buildActionTile(
            icon: Icons.info_outline_rounded,
            title: 'À propos',
            subtitle: 'CineStream v1.0 — Powered by TMDB & VidSrc',
            onTap: () => _showAbout(context),
          ),

          // API Key info
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: AppRadius.card,
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.key_rounded, color: AppColors.accent, size: 18),
                    SizedBox(width: 8),
                    Text('Clés API',
                        style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Ajoutez vos clés API dans lib/config.dart pour activer toutes les fonctionnalités.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 16, endIndent: 16);

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
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
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile() {
    final languages = {'fr': 'Français', 'ar': 'العربية'};
    return ListTile(
      leading: const Icon(Icons.language_rounded, color: AppColors.textSecondary),
      title: const Text('Langue de l\'interface',
          style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(languages[_settings.language] ?? 'Français',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () => _showLanguagePicker(context, languages),
    );
  }

  Widget _buildSubtitleTile() {
    const subtitles = {'ar': 'Arabe (AR)', 'en': 'Anglais (EN)', 'off': 'Désactivés'};
    return ListTile(
      leading: const Icon(Icons.subtitles_outlined, color: AppColors.textSecondary),
      title: const Text('Sous-titres par défaut',
          style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(subtitles[_settings.subtitleLanguage] ?? 'Arabe',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () => _showSubtitlePicker(context, subtitles),
    );
  }

  Widget _buildSourceTile() {
    const sources = {
      'vidsrc': 'VidSrc (recommandé)',
      '2embed': '2Embed',
      'vidsrcme': 'VidSrc.me',
      'multi': 'MultiEmbed',
    };
    return ListTile(
      leading: const Icon(Icons.switch_video_rounded, color: AppColors.textSecondary),
      title: const Text('Source par défaut',
          style: TextStyle(color: AppColors.textPrimary)),
      subtitle: Text(sources[_settings.defaultStreamSource] ?? 'VidSrc',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
      onTap: () => _showSourcePicker(context, sources),
    );
  }

  void _showLanguagePicker(BuildContext context, Map<String, String> languages) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Choisir la langue',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ...languages.entries.map((e) => ListTile(
                title: Text(e.value, style: const TextStyle(color: AppColors.textPrimary)),
                trailing: _settings.language == e.key
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () async {
                  setState(() => _settings.language = e.key);
                  await HiveService.saveSettings(_settings);
                  if (context.mounted) Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSubtitlePicker(BuildContext context, Map<String, String> subtitles) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Sous-titres',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ...subtitles.entries.map((e) => ListTile(
                title: Text(e.value, style: const TextStyle(color: AppColors.textPrimary)),
                trailing: _settings.subtitleLanguage == e.key
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () async {
                  setState(() => _settings.subtitleLanguage = e.key);
                  await HiveService.saveSettings(_settings);
                  if (context.mounted) Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _showSourcePicker(BuildContext context, Map<String, String> sources) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          const Text('Source de streaming',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ...sources.entries.map((e) => ListTile(
                title: Text(e.value, style: const TextStyle(color: AppColors.textPrimary)),
                trailing: _settings.defaultStreamSource == e.key
                    ? const Icon(Icons.check, color: AppColors.accent)
                    : null,
                onTap: () async {
                  setState(() => _settings.defaultStreamSource = e.key);
                  await HiveService.saveSettings(_settings);
                  if (context.mounted) Navigator.pop(context);
                },
              )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text('Voulez-vous supprimer tout votre historique ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              context.read<ProgressProvider>().clearHistory();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historique effacé')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    final json = HiveService.exportData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Données exportées (${0} favoris)')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'CineStream',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
      ),
      children: const [
        Text('Powered by TMDB API & VidSrc'),
        SizedBox(height: 8),
        Text('Ce produit utilise l\'API TMDB mais n\'est pas approuvé ou certifié par TMDB.'),
      ],
    );
  }
}
