import 'package:flutter/material.dart';

import 'custom_shimmer.dart';

class LoadingGrid extends StatelessWidget {
  const LoadingGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              childAspectRatio: 0.55,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const GridLoadingElement(),
              childCount: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class GridLoadingElement extends StatelessWidget {
  const GridLoadingElement({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight / 1.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: const CustomShimmer(),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: const CustomShimmer(),
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: const CustomShimmer(),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        );
      },
    );
  }
}
