import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../graphql_anime.dart';

class TitleOtherDetails extends StatelessWidget {
  const TitleOtherDetails({
    super.key,
    required this.name,
    required this.russian,
    required this.english,
    required this.japanese,
    required this.synonyms,
    required this.airedOn,
    required this.releasedOn,
    required this.duration,
    required this.nextEpisodeAt,
    required this.studios,
  });

  final String name;
  final String? russian;
  final String? english;
  final String? japanese;
  final List<String> synonyms;

  final String? airedOn;
  final String? releasedOn;

  final int duration;
  final DateTime? nextEpisodeAt;

  final List<GraphqlStudio> studios;

  @override
  Widget build(BuildContext context) {
    final showAiredOn = airedOn != null && airedOn!.isNotEmpty;
    final showReleasedOn = releasedOn != null && releasedOn!.isNotEmpty;

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            Text(
              'Детали',
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (studios.isNotEmpty) _Studios(studios),
            if (duration != 0)
              _Item(
                label: 'Длительность эпизода',
                title: '$duration мин.',
              ),
            if (nextEpisodeAt != null)
              _Item(
                label: 'Следующий эпизод',
                title: DateFormat.MMMMEEEEd().format(nextEpisodeAt!),
              ),
            if (showAiredOn)
              _Item(
                label: 'Начало показа',
                title: DateFormat.yMMMMd().format(DateTime.parse(airedOn!)),
              ),
            if (showReleasedOn)
              _Item(
                label: 'Конец показа',
                title: DateFormat.yMMMMd().format(DateTime.parse(releasedOn!)),
              ),
            if (studios.isNotEmpty ||
                duration != 0 ||
                nextEpisodeAt != null ||
                showAiredOn ||
                showReleasedOn)
              const Divider(),
            _Item(
              label: 'Ромадзи',
              title: name,
            ),
            if (english != null)
              _Item(
                label: 'По-английски',
                title: english ?? '',
              ),
            if (japanese != null)
              _Item(
                label: 'По-японски',
                title: japanese ?? '',
              ),
            if (synonyms.isNotEmpty)
              _Item(
                label: 'Другие названия',
                title: synonyms.join('\n'),
              ),
            const Divider(),
          ],
        ),
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(
    //         'Детали',
    //         style: context.textTheme.bodyLarge!.copyWith(
    //           fontWeight: FontWeight.bold,
    //         ),
    //       ),
    //       if (studios.isNotEmpty) _Studios(studios),
    //       if (duration != 0)
    //         _Item(
    //           label: 'Длительность эпизода',
    //           title: '$duration мин.',
    //         ),
    //       if (nextEpisodeAt != null)
    //         _Item(
    //           label: 'Следующий эпизод',
    //           title: DateFormat.MMMMEEEEd().format(nextEpisodeAt!),
    //         ),
    //       if (showAiredOn)
    //         _Item(
    //           label: 'Начало показа',
    //           title: DateFormat.yMMMMd().format(DateTime.parse(airedOn!)),
    //         ),
    //       if (showReleasedOn)
    //         _Item(
    //           label: 'Конец показа',
    //           title: DateFormat.yMMMMd().format(DateTime.parse(releasedOn!)),
    //         ),
    //       if (studios.isNotEmpty ||
    //           duration != 0 ||
    //           nextEpisodeAt != null ||
    //           showAiredOn ||
    //           showReleasedOn)
    //         const Divider(),
    //       _Item(
    //         label: 'Ромадзи',
    //         title: name,
    //       ),
    //       if (english != null)
    //         _Item(
    //           label: 'По-английски',
    //           title: english ?? '',
    //         ),
    //       if (japanese != null)
    //         _Item(
    //           label: 'По-японски',
    //           title: japanese ?? '',
    //         ),
    //       if (synonyms.isNotEmpty)
    //         _Item(
    //           label: 'Другие названия',
    //           title: synonyms.join('\n'),
    //         ),
    //       // if (airedOn != null && airedOn!.isNotEmpty) ...[
    //       //   const Divider(),
    //       //   _Title(
    //       //     label: 'Начало показа',
    //       //     title: DateFormat.yMMMMd().format(DateTime.parse(airedOn!)),
    //       //   ),
    //       // ],
    //       // if (releasedOn != null && airedOn!.isNotEmpty)
    //       //   _Title(
    //       //     label: 'Конец показа',
    //       //     title: DateFormat.yMMMMd().format(DateTime.parse(releasedOn!)),
    //       //   ),
    //       // const SizedBox(
    //       //   height: 8.0,
    //       // ),

    //       const Divider(),
    //     ],
    //   ),
    // );
  }
}

class _Studios extends StatelessWidget {
  const _Studios(this.studios);

  final List<GraphqlStudio> studios;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              'Студия',
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Wrap(
              direction: Axis.horizontal,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4.0,
              runSpacing: 8.0,
              children: [
                ...List.generate(
                  studios.length,
                  (index) => Card(
                    margin: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: InkWell(
                      //onTap: () {},
                      onTap: () => context.pushNamed(
                        'explore_search',
                        queryParameters: {'studioId': '${studios[index].id}'},
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 6.0,
                        ),
                        child: Text(
                          studios[index].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            fontSize: 14,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({
    required this.label,
    required this.title,
  });

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: context.textTheme.labelLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              title,
              maxLines: null,
              textAlign: TextAlign.right,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
