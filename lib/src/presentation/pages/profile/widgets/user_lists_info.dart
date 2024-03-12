import 'package:flutter/material.dart';

import 'package:primer_progress_bar/primer_progress_bar.dart';

import '../../../../utils/extensions/buildcontext.dart';

class UserListsInfo extends StatelessWidget {
  const UserListsInfo({
    super.key,
    required this.segmentsAnime,
    required this.segmentsManga,
    required this.animesCount,
    required this.mangasCount,
  });

  final List<Segment> segmentsAnime;
  final List<Segment> segmentsManga;
  final int animesCount;
  final int mangasCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Text(
            'Списки',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        ListHeader(
          icon: Icons.movie_rounded,
          title: 'Аниме',
          count: animesCount,
          onTap: () {},
        ),
        UserTitlesStatsItem(
          segmentsAnime,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Divider(
            height: 8,
          ),
        ),
        ListHeader(
          icon: Icons.menu_book_rounded,
          title: 'Манга и ранобе',
          count: mangasCount,
          onTap: () {},
        ),
        UserTitlesStatsItem(
          segmentsManga,
        ),
      ],
    );
  }
}

class ListHeader extends StatelessWidget {
  const ListHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // return ListTile(
    //   onTap: onTap,
    //   leading: Container(
    //     width: 42,
    //     height: 42,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(8),
    //       color: context.colorScheme.primaryContainer,
    //     ),
    //     child: Icon(
    //       icon,
    //       color: context.colorScheme.onPrimaryContainer,
    //     ),
    //   ),
    //   title: Text(
    //     title,
    //     //style: context.textTheme.bodyLarge,
    //   ),
    //   subtitle: Text(
    //     '$count всего',
    //     style: context.textTheme.bodySmall,
    //   ),
    //   trailing: const Icon(
    //     Icons.keyboard_arrow_right_rounded,
    //     // color: context.colorScheme.onSurface,
    //   ),
    // );

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: context.colorScheme.primaryContainer,
              ),
              child: Icon(
                icon,
                color: context.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyLarge,
                ),
                Text(
                  '$count всего',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            // TODO
            // const Spacer(),
            // Icon(
            //   Icons.keyboard_arrow_right_rounded,
            //   color: context.colorScheme.onSurface,
            // ),
          ],
        ),
      ),
    );
  }
}

class UserTitlesStatsItem extends StatelessWidget {
  const UserTitlesStatsItem(
    this.segments, {
    super.key,
  });

  final List<Segment> segments;

  @override
  Widget build(BuildContext context) {
    return PrimerProgressBar(
      segments: segments,
      barStyle: SegmentedBarStyle(
        backgroundColor: context.colorScheme.onInverseSurface,
        gap: 2,
      ),
    );
  }
}
