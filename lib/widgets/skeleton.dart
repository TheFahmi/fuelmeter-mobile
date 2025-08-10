import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox(
      {super.key,
      this.height = 12,
      this.width = double.infinity,
      this.borderRadius = 8});
  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceVariant;
    final highlight = Theme.of(context).colorScheme.surface;
    return Shimmer.fromColors(
      baseColor: base.withOpacity(.4),
      highlightColor: highlight.withOpacity(.6),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: base.withOpacity(.6),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.items = 6});
  final int items;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: (c, i) => Row(
        children: const [
          SkeletonBox(height: 52, width: 52, borderRadius: 12),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 14, width: 140),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 100),
              ],
            ),
          ),
        ],
      ),
      separatorBuilder: (c, i) => const SizedBox(height: 12),
      itemCount: items,
    );
  }
}
