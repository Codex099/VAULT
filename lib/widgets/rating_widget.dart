import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../theme/app_theme.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final double maxRating;
  final double itemSize;
  final bool showLabel;

  const RatingWidget({
    super.key,
    required this.rating,
    this.maxRating = 10.0,
    this.itemSize = 16,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = (rating / maxRating) * 5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBarIndicator(
          rating: normalized.clamp(0.0, 5.0),
          itemBuilder: (_, __) =>
              const Icon(Icons.star_rounded, color: AppColors.accent),
          itemCount: 5,
          itemSize: itemSize,
          unratedColor: AppColors.border,
        ),
        if (showLabel) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: itemSize * 0.75,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '/$maxRating',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: itemSize * 0.65,
            ),
          ),
        ],
      ],
    );
  }
}

class InteractiveRating extends StatefulWidget {
  final double initial;
  final void Function(double)? onRated;

  const InteractiveRating({super.key, this.initial = 0, this.onRated});

  @override
  State<InteractiveRating> createState() => _InteractiveRatingState();
}

class _InteractiveRatingState extends State<InteractiveRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _rating,
      minRating: 0.5,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 28,
      itemBuilder: (_, __) =>
          const Icon(Icons.star_rounded, color: AppColors.accent),
      unratedColor: AppColors.border,
      onRatingUpdate: (r) {
        setState(() => _rating = r);
        widget.onRated?.call(r * 2); // Convert 5-star to 10-scale
      },
    );
  }
}
