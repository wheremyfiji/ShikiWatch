import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../domain/models/manga_short.dart';
import '../../../constants/config.dart';
import '../../providers/manga_details_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/header_appbar_title.dart';
import '../../widgets/title_description.dart';
import 'widgets/manga_chips.dart';
import 'widgets/manga_info_header.dart';
import 'widgets/manga_rates_statuses.dart';
import 'widgets/user_rate_widget.dart';

const double dividerHeight = 16;

class MangaDetailPage extends ConsumerWidget {
  final MangaShort manga;

  const MangaDetailPage({super.key, required this.manga});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaDetails = ref.watch(mangaDetailsPageProvider(manga.id!));

    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: mangaDetails.title.isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: () {},
              label: mangaDetails.title.value?.userRate == null
                  ? const Text('Добавить в список')
                  : const Text('Изменить'),
              icon: mangaDetails.title.value?.userRate == null
                  ? const Icon(Icons.add)
                  : const Icon(Icons.edit),
            ),
      body: RefreshIndicator(
        onRefresh: () async => ref.refresh(mangaDetailsPageProvider(manga.id!)),
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: [
            SliverAppBar(
              stretch: true,
              pinned: true,
              floating: false,
              expandedHeight: 300,
              title: HeaderAppBarTitle(
                text: manga.russian ?? manga.name ?? '[Без навзвания]',
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
                        AppConfig.staticUrl + (manga.url ?? ''),
                        mode: LaunchMode.externalApplication,
                      );
                    } else if (value == 1) {
                      Share.share(AppConfig.staticUrl + (manga.url ?? ''));
                    }
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: MangaInfoHeader(
                  data: manga,
                ),
              ),
            ),
            ...mangaDetails.title.when(
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                  sliver: SliverToBoxAdapter(
                    child: MangaChipsWidget(
                      genres: data.genres,
                      publishers: data.publishers,
                      score: manga.score,
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
                if (data.userRate != null) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: UserRateWidget(
                        manga: manga,
                        data: data,
                      ),
                    ),
                  ),
                ],
                if (mangaDetails.statsValues != []) ...[
                  SliverPadding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 0, 16, dividerHeight),
                    sliver: SliverToBoxAdapter(
                      child: MangaRatesStatusesWidget(
                        statsValues: mangaDetails.statsValues,
                      ),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 70)),
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
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(err.toString(),
                      () => ref.refresh(mangaDetailsPageProvider(manga.id!))),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
