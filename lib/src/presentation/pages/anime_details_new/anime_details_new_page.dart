import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../services/preferences/preferences_service.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../widgets/custom_flexible_space.dart';
import '../../../domain/enums/anime_source.dart';
import '../../../domain/models/pages_extra.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/share_bottom_sheet.dart';
import '../../widgets/title_description.dart';
import '../../../domain/enums/shiki_gql.dart';
import '../../widgets/square_button.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/cached_image.dart';
import '../../../constants/config.dart';
import '../../../utils/app_utils.dart';

import '../anime_soures/anilibria/anilibria_source_page.dart';
import '../anime_soures/anime365/anime365_source_page.dart';
import '../anime_details/anime_user_rate_bottom_sheet.dart';
import '../anime_soures/anilib/anilib_source_page.dart';
import '../anime_soures/kodik/kodik_source_page.dart';
import '../anime_soures/source_modal_sheet.dart';
import '../anime_details/similar_animes.dart';
import '../anime_details/external_links.dart';
import '../anime_details/rating_dialog.dart';
import '../anime_details/videos_page.dart';

import 'components/title_other_details.dart';
import 'components/title_screenshots.dart';
import 'components/title_characters.dart';
import 'components/title_comments.dart';
import 'components/title_related.dart';
import 'components/title_header.dart';
import 'components/title_genres.dart';

import 'graphql_anime.dart';
import 'graphql_anime_ext.dart';

class AnimeDetailsNewPage extends ConsumerStatefulWidget {
  const AnimeDetailsNewPage(this.extra, {super.key});

  final TitleDetailsPageExtra extra;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnimeDetailsNewPageState();
}

class _AnimeDetailsNewPageState extends ConsumerState<AnimeDetailsNewPage> {
  late double flexibleHeight;

  @override
  void didChangeDependencies() {
    flexibleHeight = MediaQuery.sizeOf(context).height / 2;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.extra.id;
    final titleAsync = ref.watch(animeDetailsProvider(id));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(animeDetailsProvider(id).notifier).refresh(),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              ...titleAsync.when(
                skipLoadingOnReload: true,
                data: (title) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      automaticallyImplyLeading: false,
                      leading: IconButton(
                        onPressed: GoRouter.of(context).pop,
                        icon: const Icon(Icons.arrow_back),
                        color: context.colorScheme.onBackground,
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            ShareBottomSheet.show(
                              context,
                              header: ListTile(
                                leading: SizedBox(
                                  width: 48,
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: CachedImage(
                                        '${AppConfig.staticUrl}/system/animes/original/${title.id}.jpg',
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  title.russian ?? title.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${title.kind.rusName} • ${title.status.rusName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              url: title.url,
                            );
                          },
                          icon: const Icon(Icons.share_rounded),
                          iconSize: 22,
                        )
                      ],
                      expandedHeight: kToolbarHeight + flexibleHeight,
                      flexibleSpace: CustomFlexibleSpace(
                        title: title.russian ?? title.name,
                        style: TextStyle(
                          fontSize: 18,
                          color: context.theme.colorScheme.onBackground,
                        ),
                        act: true,
                        background: TitleHeader(title),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          children: [
                            Expanded(
                              child: title.userRate == null
                                  ? UserRateButton(
                                      title: 'Добавить в список',
                                      icon: _getUserRateButtonIcon(null),
                                      onTap: () =>
                                          AnimeUserRateBottomSheet.show(
                                        context,
                                        anime: title.toAnime,
                                        update: false,
                                      ),
                                    )
                                  : UserRateButton(
                                      title: _getUserRateButtonText(
                                        status: title.userRate!.status,
                                        episodes: title.userRate!.episodes,
                                        totalEpisodes: title.episodes,
                                        score: title.userRate!.score,
                                      ),
                                      icon: _getUserRateButtonIcon(
                                          title.userRate!.status),
                                      onTap: () =>
                                          AnimeUserRateBottomSheet.show(
                                        context,
                                        anime: title.toAnime,
                                        update: false,
                                      ),
                                    ),
                            ),
                            if ([
                              TitleKind.tv,
                              TitleKind.movie,
                              TitleKind.ova,
                              TitleKind.ona,
                              TitleKind.special,
                              TitleKind.tvSpecial,
                            ].contains(title.kind))
                              PlayButton(title),
                          ],
                        ).animate().fade(),
                      ),
                    ),
                    if (title.descriptionLength > 0)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: TitleDescriptionFromHtml(
                            title.descriptionLength > 0
                                ? title.description
                                : 'Описание отсутствует',
                            shouldExpand: !AppUtils.instance.isDesktop &&
                                title.descriptionLength > 500,
                          ).animate().fade(),
                        ),
                      ),
                    if (title.genres.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 14, 0, 10),
                        sliver: SliverToBoxAdapter(
                          child: TitleGenres(title.genres).animate().fade(),
                        ),
                      ),
                    if (title.characterRoles.isNotEmpty)
                      TitleCharacters(title.characterRoles),
                    if (title.related.isNotEmpty)
                      TitleRelated(
                        id: title.id,
                        name: title.russian ?? title.name,
                        related: title.related,
                      ),
                    if (title.screenshots.isNotEmpty)
                      SliverToBoxAdapter(
                        child: AnimeScreenshots(title.screenshots),
                      ),
                    TitleOtherDetails(
                      name: title.name,
                      russian: title.russian,
                      english: title.english,
                      japanese: title.japanese,
                      synonyms: title.synonyms,
                      licensors: title.licensors,
                      airedOn: title.airedOn,
                      releasedOn: title.releasedOn,
                      duration: title.duration,
                      nextEpisodeAt: title.nextEpisodeAt,
                      studios: title.studios,
                      origin: title.origin.rusName,
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate.fixed(
                        [
                          ListTile(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        SimilarAnimesPage(
                                  animeId: title.id,
                                  name: title.russian ?? title.name,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                            leading: const Icon(Icons.join_inner),
                            title: const Text('Похожее'),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                            ),
                          ),
                          ListTile(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        ExternalLinksWidget(
                                  animeId: title.id,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                            leading: const Icon(Icons.link),
                            title: const Text('Ссылки'),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                            ),
                          ),
                          ListTile(
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        AnimeVideosPage(
                                  id: title.id,
                                  name: title.russian ?? title.name,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            ),
                            leading: const Icon(Icons.movie_rounded),
                            title: const Text('Видео'),
                            trailing: const Icon(
                              Icons.chevron_right_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (title.topic != null) ...[
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(),
                        ),
                      ),
                      TitleComments(
                        id: title.topic!.id,
                        count: title.topic!.commentsCount,
                        name: title.russian ?? title.name,
                      ),
                    ],
                  ];
                },
                loading: () => [
                  const SliverAppBar(),
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
                error: (error, stackTrace) => [
                  const SliverAppBar(),
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                      error.toString(),
                      () =>
                          ref.read(animeDetailsProvider(id).notifier).refresh(),
                    ),
                  ),
                ],
              ),
              SliverPadding(
                padding: EdgeInsets.only(
                  bottom: context.padding.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _getUserRateButtonIcon(RateStatus? status) {
    return switch (status) {
      RateStatus.planned => Icons.event_available_rounded,
      RateStatus.watching => Icons.remove_red_eye_rounded,
      RateStatus.rewatching => Icons.refresh_rounded,
      RateStatus.completed => Icons.done_all_rounded,
      RateStatus.onHold => Icons.pause_rounded,
      RateStatus.dropped => Icons.close_rounded,
      _ => Icons.bookmark_add_rounded,
    };
  }

  static String _getUserRateButtonText({
    required RateStatus status,
    required int episodes,
    required int totalEpisodes,
    required int score,
  }) {
    String add;

    switch (status) {
      case RateStatus.watching || RateStatus.rewatching || RateStatus.onHold:
        add = ' • $episodes/$totalEpisodes';
        break;

      case RateStatus.completed || RateStatus.dropped:
        add = ' • $score ★';
        break;
      default:
        add = '';
    }

    return status.rusName + add;
  }
}

class PlayButton extends ConsumerWidget {
  const PlayButton(this.title, {super.key});

  final GraphqlAnime title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: SquareButton(
        icon: Icons.play_arrow_rounded,
        onTap: () => _onTap(ctx: context, ref: ref),
        onLongPress: () => _onTap(ctx: context, ref: ref, forceAlwaysAsk: true),
      ),
    );
  }

  void _onTap(
      {required BuildContext ctx,
      required WidgetRef ref,
      bool forceAlwaysAsk = false}) async {
    if ([AnimeRating.r, AnimeRating.rPlus, AnimeRating.rx]
            .contains(title.rating) ||
        title.isCensored) {
      final allowExp = ref.read(preferencesProvider).getShikiAllowExpContent();

      if (!allowExp) {
        bool? dialogValue = await showDialog<bool>(
          barrierDismissible: false,
          context: ctx,
          builder: (context) => const RatingDialog(),
        );

        if (dialogValue == null || !dialogValue) {
          return;
        } else {
          await ref
              .read(settingsProvider.notifier)
              .setShikiAllowExpContent(true);
        }
      }
    }

    final animeSource =
        ref.read(settingsProvider.select((settings) => settings.animeSource));

    List<String> searchList = [title.name];

    if (title.english != null) {
      searchList.add(title.english!);
    }

    for (var e in title.synonyms) {
      searchList.add(e);
    }

    searchList.add(title.russian ?? '');

    final extra = AnimeSourcePageExtra(
      shikimoriId: title.id,
      animeName: (title.russian == '' ? title.name : title.russian) ?? '',
      searchName: title.name,
      epWatched: title.userRate?.episodes ?? 0,
      imageUrl: '/system/animes/original/${title.id}.jpg',
      searchList: searchList,
    );

    if (forceAlwaysAsk) {
      // ignore: use_build_context_synchronously
      return SelectSourceSheet.show(
        ctx,
        extra: extra,
      );
    }

    return switch (animeSource) {
      AnimeSource.alwaysAsk =>
        // ignore: use_build_context_synchronously
        SelectSourceSheet.show(
          ctx,
          extra: extra,
        ),
      // ignore: use_build_context_synchronously
      AnimeSource.libria => Navigator.push(
          ctx,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                AnilibriaSourcePage(extra),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
      // ignore: use_build_context_synchronously
      AnimeSource.kodik => Navigator.push(
          ctx,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                KodikSourcePage(extra),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
      // ignore: use_build_context_synchronously
      AnimeSource.anilib => SelectSourceSheet.show(
          ctx,
          extra: extra,
        ),
      // Navigator.push(
      //     ctx,
      //     PageRouteBuilder(
      //       pageBuilder: (context, animation1, animation2) =>
      //           AnilibSourcePage(extra),
      //       transitionDuration: Duration.zero,
      //       reverseTransitionDuration: Duration.zero,
      //     ),
      //   ),
      // ignore: use_build_context_synchronously
      AnimeSource.anime365 => Navigator.push(
          ctx,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                Anime365SourcePage(extra),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        ),
    };
  }
}

class UserRateButton extends StatelessWidget {
  const UserRateButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0, // 42
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colorScheme.primary,
            context.colorScheme.tertiary,
          ],
          stops: const [
            0.25,
            1.0,
          ],
        ),
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  icon,
                  size: 18.0,
                  color: context.colorScheme.onPrimary,
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: context.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Stack(
          //   children: [
          //     Align(
          //       alignment: Alignment.center,
          //       child: Padding(
          //         padding: const EdgeInsets.symmetric(horizontal: 12.0),
          //         child: Row(
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           children: [
          //             Icon(
          //               icon,
          //               size: 18.0,
          //               color: context.colorScheme.onPrimary,
          //             ),
          //             const SizedBox(
          //               width: 8.0,
          //             ),
          //             Expanded(
          //               child: Text(
          //                 title,
          //                 maxLines: 1,
          //                 overflow: TextOverflow.ellipsis,
          //                 style: TextStyle(
          //                   fontWeight: FontWeight.w500,
          //                   color: context.colorScheme.onPrimary,
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     // Align(
          //     //   alignment: Alignment.bottomLeft,
          //     //   child: LinearProgressIndicator(
          //     //     value: 0.8,
          //     //     minHeight: 4.0,
          //     //     borderRadius: BorderRadius.circular(4.0),
          //     //     //  onSurfaceVariant
          //     //     backgroundColor: context.colorScheme.primary,
          //     //     color: context.colorScheme.tertiary,
          //     //   ),
          //     // ),
          //   ],
          // ),
        ),
      ),
    );
  }
}
