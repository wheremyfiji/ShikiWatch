import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/shiki_utils.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/image_with_shimmer.dart';

import '../related_titles.dart';

class TitleRelatedWidget extends ConsumerWidget {
  final int id;

  const TitleRelatedWidget({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedTitlesAnimeProvider(id));

    return related.when(
      data: (data) {
        if (data.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final dataList = data.toList();
        final hasMore = dataList.length > 3;

        return SliverList.separated(
          itemCount: hasMore ? 4 : dataList.length + 1,
          separatorBuilder: (context, index) =>
              SizedBox(height: index == 0 ? 6 : 10),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 4),
                    child: Text(
                      'Связанное',
                      style: context.textTheme.bodyLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '(${dataList.length})',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorScheme.onBackground.withOpacity(
                        0.8,
                      ),
                    ),
                  ),
                  if (hasMore) ...[
                    const Spacer(),
                    IconButton(
                      style: const ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              RelatedTitles(related: dataList),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                    ),
                  ],
                ],
              );
            }

            final info = dataList[index - 1];
            // ignore: prefer_typing_uninitialized_variables
            var title;
            if (info.anime != null) {
              title = info.anime!;
            } else {
              title = info.manga!;
            }
            final relation = info.relationRussian ?? info.relation ?? '';
            final kind = getKind(title.kind ?? '');
            final isManga = kindIsManga(title!.kind ?? '');

            final DateTime? airedOn = DateTime.tryParse(title!.airedOn ?? '');
            final int? year = airedOn?.year;

            return Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Material(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                clipBehavior: Clip.hardEdge,
                child: InkWell(
                  onTap: () {
                    if (isManga) {
                      context.pushNamed(
                        'library_manga',
                        pathParameters: <String, String>{
                          'id': (title!.id!).toString(),
                        },
                        extra: title,
                      );
                    } else {
                      final extra = AnimeDetailsPageExtra(
                        id: title.id!,
                        label: (title.russian == ''
                                ? title.name
                                : title.russian) ??
                            '',
                      );
                      context.pushNamed(
                        'library_anime',
                        pathParameters: <String, String>{
                          'id': (title!.id!).toString(),
                        },
                        extra: extra,
                      );
                    }
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 70, //60
                        child: AspectRatio(
                          aspectRatio: 0.703,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageWithShimmerWidget(
                              imageUrl: AppConfig.staticUrl +
                                  (title?.image?.original ?? ''),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              (title?.russian == ''
                                      ? title?.name
                                      : title?.russian) ??
                                  '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            year == null
                                ? Text(
                                    'Анонс • $kind • $relation',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: context.colorScheme.onBackground
                                          .withOpacity(0.8),
                                    ),
                                  )
                                : Text(
                                    '$year год • $kind • $relation',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        context.textTheme.bodySmall?.copyWith(
                                      color: context.colorScheme.onBackground
                                          .withOpacity(0.8),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      error: (error, stackTrace) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
      loading: () {
        //return const SliverToBoxAdapter(child: SizedBox.shrink());
        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Связанное',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 8,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 100.0,
                    child: Shimmer.fromColors(
                      baseColor: Theme.of(context).colorScheme.surface,
                      highlightColor:
                          Theme.of(context).colorScheme.onInverseSurface,
                      child: Container(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fade(),
          ),
        );
      },
    );
  }
}
