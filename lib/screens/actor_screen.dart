import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../models/actor_model.dart';
import '../services/tmdb_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/shimmer_card.dart';

class ActorScreen extends StatefulWidget {
  final String actorId;
  const ActorScreen({super.key, required this.actorId});

  @override
  State<ActorScreen> createState() => _ActorScreenState();
}

class _ActorScreenState extends State<ActorScreen> {
  ActorModel? _actor;
  bool _loading = true;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final actor = await TmdbService.getActorDetails(int.parse(widget.actorId));
      if (mounted) setState(() { _actor = actor; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const ShimmerDetailHeader()
          : _actor == null
              ? const Center(child: Text('Acteur introuvable'))
              : _buildDetail(),
    );
  }

  Widget _buildDetail() {
    final actor = _actor!;
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: AppColors.background,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
          title: Text(actor.name),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: actor.fullProfileUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: actor.fullProfileUrl,
                              width: 100, height: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100, height: 100,
                              color: AppColors.surfaceVariant,
                              child: const Icon(Icons.person, color: AppColors.textMuted, size: 50),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(actor.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800)),
                          if (actor.knownForDepartment != null) ...[
                            const SizedBox(height: 4),
                            Text(actor.knownForDepartment!,
                                style: const TextStyle(
                                    color: AppColors.accent, fontSize: 13)),
                          ],
                          if (actor.birthday != null) ...[
                            const SizedBox(height: 6),
                            _infoRow(Icons.cake_outlined, actor.birthday!),
                          ],
                          if (actor.placeOfBirth != null)
                            _infoRow(Icons.place_outlined, actor.placeOfBirth!),
                        ],
                      ),
                    ),
                  ],
                ),
                // Biography
                if (actor.biography != null && actor.biography!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Biographie',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  AnimatedCrossFade(
                    duration: AppDurations.normal,
                    crossFadeState: _expanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(actor.biography!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: AppColors.textSecondary, height: 1.6)),
                        GestureDetector(
                          onTap: () => setState(() => _expanded = true),
                          child: const Text('Voir plus',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(actor.biography!,
                            style: const TextStyle(
                                color: AppColors.textSecondary, height: 1.6)),
                        GestureDetector(
                          onTap: () => setState(() => _expanded = false),
                          child: const Text('Voir moins',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
                // Filmography
                if (actor.credits.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const Text('Filmographie',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 250,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: actor.credits.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final credit = actor.credits[i];
                        return MovieCard(
                          title: credit.title,
                          posterUrl: credit.fullPosterUrl,
                          rating: credit.voteAverage,
                          onTap: () {
                            final type = credit.mediaType ?? 'movie';
                            if (type == 'movie') {
                              context.push('/movie/${credit.id}');
                            } else {
                              context.push('/series/${credit.id}');
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textMuted, size: 13),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
