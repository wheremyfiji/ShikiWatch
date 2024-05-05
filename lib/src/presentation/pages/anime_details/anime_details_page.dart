import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../services/preferences/preferences_service.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/shiki_utils.dart';
import '../../providers/anime_details_provider.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../constants/config.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../../domain/enums/anime_source.dart';
import '../../widgets/share_bottom_sheet.dart';
import '../../widgets/title_description.dart';

import '../anime_soures/anilibria/anilibria_source_page.dart' hide TitleInfo;
import '../anime_soures/anilib/anilib_source_page.dart';
import '../anime_soures/kodik/kodik_source_page.dart';
import '../anime_soures/source_modal_sheet.dart';

import 'components/title_actions.dart';
import 'components/title_characters.dart';
import 'components/title_genres_studios.dart';
import 'components/title_info.dart';
import 'components/title_name.dart';
import 'components/title_poster.dart';
import 'components/title_rates.dart';
import 'components/title_related.dart';
import 'components/title_screenshots.dart';
import 'components/title_videos.dart';

import 'rating_dialog.dart';

class AnimeDetailsPage extends ConsumerWidget {
  final TitleDetailsPageExtra extra;

  const AnimeDetailsPage({
    super.key,
    required this.extra,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleInfo = ref.watch(titleInfoPageProvider(extra.id));

    return Scaffold(
      floatingActionButton: titleInfo.title.when(
        data: (data) => data.kind == 'music'
            ? null
            : FloatingActionButton.extended(
                //heroTag: UniqueKey(),
                heroTag: null,
                onPressed: () async {
                  // if (titleInfo.rating == '18+') {
                  if (['R-17', 'R+', 'Rx'].contains(titleInfo.rating)) {
                    final allowExp = ref
                            .read(preferencesProvider)
                            .sharedPreferences
                            .getBool('allowExpContent') ??
                        false;

                    if (!allowExp) {
                      bool? dialogValue = await showDialog<bool>(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) => const RatingDialog(),
                      );

                      if (dialogValue == null || !dialogValue) {
                        return;
                      } else {
                        await ref
                            .read(preferencesProvider)
                            .sharedPreferences
                            .setBool('allowExpContent', true);
                      }
                    }
                  }

                  final animeSource = ref.read(settingsProvider
                      .select((settings) => settings.animeSource));

                  List<String> searchList = [data.name ?? ''];

                  data.english?.forEach((e) {
                    searchList.add(e);
                  });

                  data.synonyms?.forEach((e) {
                    searchList.add(e);
                  });

                  searchList.add(data.russian ?? '');

                  final extra = AnimeSourcePageExtra(
                    shikimoriId: data.id!,
                    animeName:
                        (data.russian == '' ? data.name : data.russian) ?? '',
                    searchName:
                        data.name ?? data.english?[0] ?? data.russian ?? '',
                    epWatched: titleInfo.currentProgress,
                    imageUrl: data.image?.original ?? '',
                    searchList: searchList,
                  );

                  return switch (animeSource) {
                    // ignore: use_build_context_synchronously
                    AnimeSource.alwaysAsk => SelectSourceSheet.show(
                        context,
                        extra: extra,
                      ),
                    // ignore: use_build_context_synchronously
                    AnimeSource.libria => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AnilibriaSourcePage(extra),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                    // ignore: use_build_context_synchronously
                    AnimeSource.kodik => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              KodikSourcePage(extra),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                    // ignore: use_build_context_synchronously
                    AnimeSource.anilib => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) =>
                              AnilibSourcePage(extra),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      ),
                  };
                },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Смотреть'),
              ),
        error: (error, stackTrace) => null,
        loading: () => null,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(titleInfoPageProvider(extra.id)),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            clipBehavior: Clip.none,
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  extra.label,
                  style: TextStyle(
                    fontSize: 18,
                    color: context.theme.colorScheme.onBackground,
                  ),
                ),
                actions: titleInfo.title.valueOrNull == null
                    ? null
                    : [
                        IconButton(
                          onPressed: () {
                            final title = titleInfo.title.valueOrNull;
                            // а ловко ты это придумал
                            if (title == null) {
                              return;
                            }

                            final subtitle =
                                '${getKind(title.kind ?? '')} • ${getStatus(title.status ?? '')}';

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
                                        AppConfig.staticUrl +
                                            title.image!.original!,
                                        memCacheWidth: 144,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  title.russian ?? title.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              url: title.url!,
                            );
                          },
                          icon: const Icon(Icons.share_rounded),
                          iconSize: 22,
                        ),
                      ],
              ),
              ...titleInfo.title.when(
                skipLoadingOnRefresh: false,
                data: (anime) => [
                  SliverToBoxAdapter(
                    child: TitlePoster(
                      anime.image?.original ?? '',
                    )
                        .animate()
                        .fade()
                        .slideY(begin: .05, end: 0, curve: Curves.easeOutCirc),
                  ),
                  SliverToBoxAdapter(
                    child: TitleActions(
                      anime,
                    ).animate().fade(),
                  ),
                  SliverToBoxAdapter(
                    child: TitleName(
                      animeId: extra.id,
                      title:
                          (anime.russian == '' ? anime.name : anime.russian) ??
                              '',
                      subTitle: anime.name,
                      rating: titleInfo.rating,
                      score: anime.score,
                      english: anime.english,
                      japanese: anime.japanese,
                      synonyms: anime.synonyms,
                    ).animate().fade(),
                  ),
                  SliverToBoxAdapter(
                    child: TitleInfo(
                      anime,
                      duration: titleInfo.duration,
                      nextEp: titleInfo.nextEp,
                    ).animate().fade(),
                  ),
                  SliverToBoxAdapter(
                    child: TitleGenresStudios(
                      genres: anime.genres,
                      studios: anime.studios,
                    ).animate().fade(),
                  ),
                  if (anime.description != null &&
                      anime.description!.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      sliver: SliverToBoxAdapter(
                        child: RepaintBoundary(
                          child: TitleDescriptionFromHtml(
                            anime.descriptionHtml!,
                            shouldExpand: !AppUtils.instance.isDesktop &&
                                anime.description!.length > 500,
                          ).animate().fade(),
                        ),
                      ),
                    ),
                  if (titleInfo.statsValues.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverToBoxAdapter(
                        child: TitleRatesWidget(
                          titleInfo.statsValues,
                        ).animate().fade(),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: AnimeCharactersWidget(
                      anime.id!,
                    ),
                  ),
                  TitleRelatedWidget(
                    id: anime.id!,
                  ),
                  if (anime.screenshots != null &&
                      anime.screenshots!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: TitleScreenshots(anime).animate().fade(),
                    ),
                  if (anime.videos != null && anime.videos!.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 16),
                      sliver: SliverToBoxAdapter(
                        child: TitleVideosWidget(anime).animate().fade(),
                      ),
                    ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 70,
                    ),
                  ),
                ],
                error: (err, stack) => [
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                      err.toString(),
                      () => ref.invalidate(titleInfoPageProvider(extra.id)),
                    ),
                  ),
                ],
                loading: () => [
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
