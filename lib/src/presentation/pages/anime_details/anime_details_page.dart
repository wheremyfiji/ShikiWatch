import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../constants/config.dart';
import '../../../domain/models/animes.dart';
import '../../../services/shared_pref/shared_preferences_provider.dart';
import '../../providers/anime_details_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/header_appbar_title.dart';

import 'rating_dialog.dart';
import 'studio_select_page.dart';
import 'widgets/anime_actions.dart';
import 'widgets/anime_chips_widger.dart';
import 'widgets/anime_videos_widget.dart';
import 'widgets/details_screenshots.dart';
import 'widgets/info_header.dart';
import 'widgets/rates_statuses_widget.dart';
import '../../widgets/title_description.dart';
import 'widgets/user_anime_rate.dart';

const double dividerHeight = 16;

class AnimeDetailsPage extends ConsumerWidget {
  final Animes animeData;

  const AnimeDetailsPage({
    super.key,
    required this.animeData,
  });

  void pushStudioSelectPage({
    required BuildContext ctx,
    required int id,
    required String name,
    required int ep,
    required String imgUrl,
  }) {
    Navigator.push(
      ctx,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => StudioSelectPage(
          //animeId: titleInfo.id,
          shikimoriId: id,
          animeName: name,
          epWatched: ep,
          imageUrl: imgUrl,
        ),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleInfo = ref.watch(titleInfoPageProvider(animeData.id!));

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton:
          // titleInfo.isAnons
          //     ? const SizedBox.shrink()
          //     :
          titleInfo.title.isLoading || animeData.kind == 'music'
              ? null
              : FloatingActionButton.extended(
                  onPressed: () async {
                    if (titleInfo.rating == '18+') {
                      final allowExp = ref
                              .read(sharedPreferencesProvider)
                              .getBool('allowExpContent') ??
                          false;

                      if (!allowExp) {
                        bool? dialogValue = await showDialog<bool>(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => const RatingDialog(),
                        );

                        if (dialogValue ?? false) {
                          await ref
                              .read(sharedPreferencesProvider)
                              .setBool('allowExpContent', true);
                          // ignore: use_build_context_synchronously
                          pushStudioSelectPage(
                            ctx: context,
                            id: animeData.id ?? 0,
                            name: animeData.russian ??
                                animeData.name ??
                                '[Без навзвания]',
                            ep: titleInfo.currentProgress,
                            imgUrl: animeData.image?.original ?? '',
                          );
                        }
                      } else {
                        pushStudioSelectPage(
                          ctx: context,
                          id: animeData.id ?? 0,
                          name: animeData.russian ??
                              animeData.name ??
                              '[Без навзвания]',
                          ep: titleInfo.currentProgress,
                          imgUrl: animeData.image?.original ?? '',
                        );
                      }
                    } else {
                      pushStudioSelectPage(
                        ctx: context,
                        id: animeData.id ?? 0,
                        name: animeData.russian ??
                            animeData.name ??
                            '[Без навзвания]',
                        ep: titleInfo.currentProgress,
                        imgUrl: animeData.image?.original ?? '',
                      );
                    }
                  },
                  label: const Text('Смотреть'),
                  icon: const Icon(Icons.play_arrow),
                ),
      body: RefreshIndicator(
        onRefresh: () async =>
            ref.refresh(titleInfoPageProvider(animeData.id!)),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverAppBar(
              stretch: true,
              pinned: true,
              floating: false,
              expandedHeight: 300,
              title: HeaderAppBarTitle(
                text: animeData.russian ?? animeData.name ?? '[Без навзвания]',
              ),
              actions: [
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
                    ];
                  },
                  onSelected: (value) {
                    if (value == 0) {
                      launchUrlString(
                        '${AppConfig.staticUrl}/animes/${animeData.id}',
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (value == 1) {
                      Share.share(AppConfig.staticUrl + (animeData.url ?? ''));
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: AnimeInfoHeader(
                  data: animeData,
                  duration: titleInfo.duration,
                  favoured: titleInfo.isFavor,
                  nextEp: titleInfo.nextEp ?? '',
                  rating: titleInfo.rating,
                ),
              ),
            ),
            ...titleInfo.title.when(
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: AnimeActionsWidget(
                      anime: data,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: UserAnimeRateWidget(
                        animeData, data, titleInfo.userImage),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: AnimeChipsWidget(
                      genres: data.genres,
                      studios: data.studios,
                      score: animeData.score,
                    ),
                  ),
                ),
                if (data.description != null) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: TitleDescription(data.descriptionHtml!),
                    ),
                  ),
                ],
                if (titleInfo.statsValues != []) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeRatesStatusesWidget(
                          statsValues: titleInfo.statsValues),
                    ),
                  ),
                ],
                if (data.screenshots != null &&
                    data.screenshots!.isNotEmpty) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeScreenshots(data),
                    ),
                  ),
                ],
                if (data.videos != null && data.videos!.isNotEmpty) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: AnimeVideosMobileWidget(data),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 70)),
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(err.toString(),
                      () => ref.refresh(titleInfoPageProvider(animeData.id!))),
                ),
              ],
              loading: () => [
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 130),
                          child: const CircularProgressIndicator()),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
