import 'package:flutter/material.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../services/preferences/preferences_service.dart';
import '../../providers/anime_details_provider.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../constants/config.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/error_widget.dart';
import '../../../domain/enums/anime_source.dart';
import '../../widgets/title_description.dart';

import 'anime_soures/anilibria_source_page.dart';
import 'anime_soures/kodik_source_page.dart';
import 'anime_soures/source_modal_sheet.dart';
import 'external_links.dart';
import 'widgets/anime_actions.dart';
import 'widgets/anime_chips_widger.dart';
import 'widgets/anime_videos_widget.dart';
import 'widgets/characters_widget.dart';
import 'widgets/details_screenshots.dart';
import 'widgets/info_header.dart';
import 'widgets/rates_statuses_widget.dart';
import 'widgets/related_widget.dart';
import 'widgets/user_anime_rate.dart';

import 'rating_dialog.dart';

const double dividerHeight = 16;

class AnimeDetailsPage extends ConsumerWidget {
  final AnimeDetailsPageExtra extra;

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
                  if (titleInfo.rating == '18+') {
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

                  if (animeSource == AnimeSource.alwaysAsk) {
                    // ignore: use_build_context_synchronously
                    SourceModalSheet.show(
                      context: context,
                      shikimoriId: data.id!,
                      epWatched: titleInfo.currentProgress,
                      animeName:
                          (data.russian == '' ? data.name : data.russian) ?? '',
                      search:
                          data.name ?? data.english?[0] ?? data.russian ?? '',
                      imageUrl: data.image?.original ?? '',
                    );
                  } else if (animeSource == AnimeSource.libria) {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            AnilibriaSourcePage(
                          shikimoriId: data.id!,
                          animeName:
                              (data.russian == '' ? data.name : data.russian) ??
                                  '',
                          searchName: data.name ??
                              data.english?[0] ??
                              data.russian ??
                              '',
                          epWatched: titleInfo.currentProgress,
                          imageUrl: data.image?.original ?? '',
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  } else {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            KodikSourcePage(
                          shikimoriId: data.id!,
                          animeName:
                              (data.russian == '' ? data.name : data.russian) ??
                                  '',
                          searchName: data.name ??
                              data.english?[0] ??
                              data.russian ??
                              '',
                          epWatched: titleInfo.currentProgress,
                          imageUrl: data.image?.original ?? '',
                        ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  }
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
            slivers: [
              SliverAppBar(
                pinned: true,
                //stretch: true,
                expandedHeight:
                    titleInfo.title.valueOrNull == null ? null : 280,
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
                        PopupMenuButton(
                          tooltip: '',
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem<int>(
                                value: 0,
                                child: Text("Открыть в браузере"),
                              ),
                              const PopupMenuItem<int>(
                                value: 1,
                                child: Text("Поделиться"),
                              ),
                              const PopupMenuItem<int>(
                                value: 2,
                                child: Text("Ссылки"),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 0) {
                              launchUrlString(
                                '${AppConfig.staticUrl}/animes/${extra.id}',
                                mode: LaunchMode.externalApplication,
                              );
                            } else if (value == 1) {
                              Share.share(AppConfig.staticUrl +
                                  (titleInfo.title.valueOrNull!.url ?? ''));
                            } else if (value == 2) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (context, animation1, animation2) =>
                                          ExternalLinksWidget(
                                    animeId: extra.id,
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            }
                          },
                        ),
                      ],
                flexibleSpace: titleInfo.title.valueOrNull == null
                    ? null
                    : FlexibleSpaceBar(
                        background: AnimeInfoHeader(
                          titleInfo.title.value!,
                          duration: titleInfo.duration,
                          favoured: titleInfo.isFavor,
                          nextEp: titleInfo.nextEp ?? '',
                          rating: titleInfo.rating,
                        ).animate().fade(),
                      ),
              ),
              ...titleInfo.title.when(
                skipLoadingOnRefresh: false,
                data: (data) => [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    sliver: SliverToBoxAdapter(
                      child: AnimeActionsWidget(
                        anime: data,
                        onBtnPress: () => showModalBottomSheet<void>(
                          context: context,
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width >= 700
                                ? 700
                                : double.infinity,
                          ),
                          useRootNavigator: true,
                          isScrollControlled: true,
                          enableDrag: false,
                          useSafeArea: true,
                          builder: (context) {
                            return SafeArea(
                              child: AnimeUserRateBottomSheet(
                                data: data,
                                needUpdate: true,
                              ),
                            );
                          },
                        ),
                      ).animate().fadeIn(),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 6),
                    sliver: SliverToBoxAdapter(
                      child: AnimeChipsWidget(
                        genres: data.genres,
                        studios: data.studios,
                        score: data.score,
                        rating: titleInfo.rating,
                      ).animate().fade(),
                    ),
                  ),
                  if (data.description != null) ...[
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                      sliver: SliverToBoxAdapter(
                        child: TitleDescription(
                          data.descriptionHtml!,
                        ).animate().fade(),
                      ),
                    ),
                  ],
                  if (titleInfo.statsValues != []) ...[
                    SliverPadding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                      sliver: SliverToBoxAdapter(
                        child: AnimeRatesStatusesWidget(
                          statsValues: titleInfo.statsValues,
                        ).animate().fade(),
                      ),
                    ),
                  ],
                  SliverToBoxAdapter(
                    child: CharactersWidget(
                      data.id!,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: RelatedWidget(
                      id: data.id!,
                    ),
                  ),
                  if (data.screenshots != null &&
                      data.screenshots!.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: AnimeScreenshots(data).animate().fade(),
                    ),
                  ],
                  if (data.videos != null && data.videos!.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: dividerHeight),
                      sliver: SliverToBoxAdapter(
                        child: AnimeVideosMobileWidget(data).animate().fade(),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 70)),
                ],
                error: (err, stack) => [
                  SliverFillRemaining(
                    child: CustomErrorWidget(err.toString(),
                        () => ref.invalidate(titleInfoPageProvider(extra.id))),
                  ),
                ],
                loading: () => [
                  const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator())),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
