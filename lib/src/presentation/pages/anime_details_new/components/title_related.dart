import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/pages_extra.dart';
import '../../../widgets/cached_image.dart';
import '../../anime_details/anime_franchise_page.dart';
import '../graphql_anime.dart';

class TitleRelated extends StatelessWidget {
  const TitleRelated({
    super.key,
    required this.id,
    required this.name,
    required this.related,
  });

  final int id;
  final String name;
  final List<GraphqlRelated> related;

  @override
  Widget build(BuildContext context) {
    final hasMore = related.length > 3;

    return SliverList.builder(
      itemCount: hasMore ? 4 : related.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Row(
              children: [
                Text(
                  'Связанное',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 3.0,
                ),
                Badge.count(
                  count: related.length,
                  backgroundColor: context.colorScheme.secondary,
                  textColor: context.colorScheme.onSecondary,
                ),
                const SizedBox(
                  width: 6.0,
                ),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AnimeFranchisePage(
                        id: id,
                        name: name,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  ),
                  child: Text(
                    'Хронология',
                    style: context.textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onSurfaceVariant,
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
                    onPressed: () => TitleRelatedBottomSheet.show(
                      context,
                      related: related,
                    ),
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        final item = related[index - 1];

        if (item.title == null) {
          return null;
        }

        return ListTile(
          onTap: () {
            final extra = TitleDetailsPageExtra(
              id: item.title!.id,
              label: (item.title!.russian == ''
                      ? item.title!.name
                      : item.title!.russian) ??
                  '',
            );

            if (item.type == RelatedType.manga) {
              context.pushNamed(
                'library_manga',
                pathParameters: <String, String>{
                  'id': (item.title!.id).toString(),
                },
                extra: extra,
              );
            } else {
              context.pushNamed(
                'library_anime',
                pathParameters: <String, String>{
                  'id': (item.title!.id).toString(),
                },
                extra: extra,
              );
            }
          },
          //minVerticalPadding: 0,
          visualDensity: VisualDensity.compact,
          leading: SizedBox(
            width: 48,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedImage(
                  item.title!.poster,
                  memCacheWidth: 144,
                ),
              ),
            ),
          ),
          title: Text(
            item.title!.russian ?? item.title!.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            '${item.title!.kind.rusName} • ${item.relationRu}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

class TitleRelatedBottomSheet extends StatelessWidget {
  final List<GraphqlRelated> related;

  const TitleRelatedBottomSheet(this.related, {super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      minChildSize: 0.5,
      initialChildSize: 0.75,
      snapSizes: const [0.75, 1.0],
      builder: (context, scrollController) {
        return SafeArea(
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'Связанное',
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Divider(height: 1),
              ),
              SliverList.builder(
                itemCount: related.length,
                itemBuilder: (context, index) {
                  final item = related[index];
                  final title = item.title;

                  if (title == null) {
                    return null;
                  }

                  return ListTile(
                    onTap: () {
                      final extra = TitleDetailsPageExtra(
                        id: title.id,
                        label: (title.russian == ''
                                ? title.name
                                : title.russian) ??
                            '',
                      );

                      if (item.type == RelatedType.manga) {
                        context.pushNamed(
                          'library_manga',
                          pathParameters: <String, String>{
                            'id': (title.id).toString(),
                          },
                          extra: extra,
                        );
                      } else {
                        context.pushNamed(
                          'library_anime',
                          pathParameters: <String, String>{
                            'id': (title.id).toString(),
                          },
                          extra: extra,
                        );
                      }
                    },
                    //minVerticalPadding: 0,
                    visualDensity: VisualDensity.compact,
                    leading: SizedBox(
                      width: 48,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedImage(
                            title.poster,
                            memCacheWidth: 144,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      title.russian ?? title.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      '${title.kind.rusName} • ${item.relationRu}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void show(BuildContext context,
      {required List<GraphqlRelated> related}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: false,
      showDragHandle: true,
      backgroundColor: context.colorScheme.background,
      elevation: 0,
      builder: (_) => SafeArea(child: TitleRelatedBottomSheet(related)),
    );
  }
}
