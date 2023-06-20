import 'package:flutter/material.dart';

import 'custom_shimmer.dart';

const int _count = 6;

class LoadingList extends StatelessWidget {
  const LoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 16),
          sliver: SliverList.builder(
            itemCount: _count,
            itemBuilder: (context, index) {
              final isLastElement = index == (_count - 1);

              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, isLastElement ? 16 : 8),
                child: const LoadingListElement(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class LoadingListElement extends StatelessWidget {
  const LoadingListElement({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 127,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: const CustomShimmer(),
      ),
    );
  }
}
