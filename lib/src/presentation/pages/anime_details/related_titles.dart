import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../constants/config.dart';
import '../../../domain/models/pages_extra.dart';
import '../../../domain/models/related_title.dart';
import '../../../utils/shiki_utils.dart';
import '../../widgets/image_with_shimmer.dart';

class RelatedTitles extends StatelessWidget {
  final List<RelatedTitle> related;

  const RelatedTitles({super.key, required this.related});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              forceElevated: innerBoxIsScrolled,
              stretch: true,
              title: const Text(
                // 'Связанное (${related.length})',
                'Связанное',
              ),
            ),
          ];
        },
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: related.length,
                  (context, index) {
                    final info = related[index];
                    // ignore: prefer_typing_uninitialized_variables
                    var title;
                    if (info.anime != null) {
                      title = info.anime!;
                    } else {
                      title = info.manga!;
                    }
                    final relation =
                        info.relationRussian ?? info.relation ?? '';
                    final kind = getKind(title.kind ?? '');
                    final isManga = kindIsManga(title!.kind ?? '');

                    final airedOn = DateTime.tryParse(title!.airedOn ?? '') ??
                        DateTime(1970);
                    final year = airedOn.year;

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
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
                                width: 60,
                                //height: 100,
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
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      '$year год • $kind • $relation',
                                      style: context.textTheme.bodySmall,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
