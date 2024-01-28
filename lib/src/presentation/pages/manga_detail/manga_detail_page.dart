import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../anime_details/components/title_characters.dart';
import '../anime_details/components/title_poster.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../providers/manga_details_provider.dart';
import '../anime_details/components/title_name.dart';
import '../../../domain/models/pages_extra.dart';
import '../../widgets/title_description.dart';
import '../../../constants/config.dart';
import '../../widgets/error_widget.dart';

import 'components/manga_actions.dart';
import 'components/manga_genres_pub.dart';
import 'components/manga_info.dart';
import 'components/manga_rates.dart';
import 'components/manga_related.dart';

class MangaDetailPage extends ConsumerWidget {
  const MangaDetailPage({super.key, required this.extra});

  //final MangaShort manga;
  final TitleDetailsPageExtra extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaDetails = ref.watch(mangaDetailsPageProvider(extra.id));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(mangaDetailsPageProvider(extra.id)),
        child: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Text(
                  extra.label,
                  style: TextStyle(
                    fontSize: 18,
                    color: context.colorScheme.onBackground,
                  ),
                ),
                actions: mangaDetails.title.valueOrNull == null
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
                            ];
                          },
                          onSelected: (value) {
                            if (value == 0) {
                              launchUrlString(
                                AppConfig.staticUrl +
                                    (mangaDetails.title.valueOrNull!.url ?? ''),
                                mode: LaunchMode.externalApplication,
                              );
                            } else if (value == 1) {
                              Share.share(
                                AppConfig.staticUrl +
                                    (mangaDetails.title.valueOrNull!.url ?? ''),
                              );
                            }
                          },
                        ),
                      ],
              ),
              ...mangaDetails.title.when(
                skipLoadingOnRefresh: false,
                data: (data) => [
                  SliverToBoxAdapter(
                    child: TitlePoster(
                      data.image?.original ?? '',
                    )
                        .animate()
                        .fade()
                        .slideY(begin: .05, end: 0, curve: Curves.easeOutCirc),
                  ),
                  SliverToBoxAdapter(
                    child: MangaActions(
                      data: data,
                    ).animate().fade(),
                  ),
                  SliverToBoxAdapter(
                    child: TitleName(
                      animeId: data.id!,
                      title:
                          (data.russian == '' ? data.name : data.russian) ?? '',
                      subTitle: data.name,
                      rating: '?',
                      score: data.score,
                      english: data.english,
                      japanese: data.japanese,
                      synonyms: data.synonyms,
                    ).animate().fade(),
                  ),
                  SliverToBoxAdapter(
                    child: MangaInfoWidget(
                      data,
                    ).animate().fade(),
                  ),
                  SliverToBoxAdapter(
                    child: MangaGenresWidget(
                      genres: data.genres,
                      publishers: data.publishers,
                    ).animate().fade(),
                  ),
                  // if (data.description != null && data.description!.isNotEmpty)
                  //   SliverPadding(
                  //     padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  //     sliver: SliverToBoxAdapter(
                  //       child: TitleDescription(
                  //         data.description!,
                  //       ).animate().fade(),
                  //     ),
                  //   ),
                  if (data.description != null && data.description!.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      sliver: SliverToBoxAdapter(
                        child: TitleDescriptionFromHtml(
                          data.descriptionHtml!,
                        ).animate().fade(),
                      ),
                    ),
                  if (mangaDetails.statsValues != [])
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      sliver: SliverToBoxAdapter(
                        child: MangaRatesWidget(
                          mangaDetails.statsValues,
                        ).animate().fade(),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: MangaCharactersWidget(
                      mangaDetails.id,
                    ),
                  ),
                  MangaRelatedWidget(
                    id: data.id!,
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 60)),
                ],
                error: (err, stack) => [
                  SliverFillRemaining(
                    child: CustomErrorWidget(
                      err.toString(),
                      () => ref.invalidate(mangaDetailsPageProvider(extra.id)),
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

class MangaCharactersWidget extends ConsumerWidget {
  final int id;

  const MangaCharactersWidget(this.id, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roles = ref.watch(mangaRolesProvider(id));

    return TitleCharactersWidget(roles);
  }
}
