import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class ShimmerCard extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const ShimmerCard({
    super.key,
    this.width = 130,
    this.height = 195,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? AppRadius.card,
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemWidth;
  final double itemHeight;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemWidth = 130,
    this.itemHeight = 195,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight + 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (_, __) => ShimmerCard(width: itemWidth, height: itemHeight),
      ),
    );
  }
}

class ShimmerBanner extends StatelessWidget {
  const ShimmerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: 580,
        width: double.infinity,
        color: AppColors.shimmerBase,
      ),
    );
  }
}

class ShimmerDetailHeader extends StatelessWidget {
  const ShimmerDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 450, color: AppColors.shimmerBase),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 48, width: 300, color: AppColors.shimmerBase,
                    decoration: BoxDecoration(borderRadius: AppRadius.card)),
                const SizedBox(height: 16),
                Container(height: 20, width: 200, color: AppColors.shimmerBase,
                    decoration: BoxDecoration(borderRadius: AppRadius.card)),
                const SizedBox(height: 32),
                Container(height: 120, color: AppColors.shimmerBase,
                    decoration: BoxDecoration(borderRadius: AppRadius.card)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
