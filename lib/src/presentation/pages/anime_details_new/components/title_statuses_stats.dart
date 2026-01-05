import 'package:flutter/material.dart';

import 'package:primer_progress_bar/primer_progress_bar.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../graphql_anime.dart';

class TitleStatusesStats extends StatelessWidget {
  const TitleStatusesStats(this.statusesStats, {super.key});

  final List<GraphqlStatusesStats> statusesStats;

  @override
  Widget build(BuildContext context) {
    final segments = statusesStats
        .map((e) => Segment(
              value: e.count,
              color: e.status.color(context.colorScheme),
              label: Text(e.status.rusName),
            ))
        .toList();

    final totalCount = statusesStats.fold(
        0, (previousValue, element) => previousValue + element.count);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'В списках',
            style: context.textTheme.bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        PrimerProgressBar(
          segments: segments,
          maxTotalValue: totalCount,
          barStyle: SegmentedBarStyle(
            backgroundColor: context.colorScheme.onInverseSurface,
            gap: 2,
          ),
          legendStyle: const SegmentedBarLegendStyle(
            spacing: 4,
            runSpacing: 2,
            padding: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
          ),
        ),
      ],
    );
  }
}
