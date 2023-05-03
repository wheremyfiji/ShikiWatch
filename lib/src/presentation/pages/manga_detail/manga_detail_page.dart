import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shikidev/src/utils/extensions/string_ext.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../domain/models/manga_ranobe.dart';
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
                    child: MangaActionsWidget(
                      manga: manga,
                      data: data,
                    ),
                  ),
                ),
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

class MangaActionsWidget extends StatelessWidget {
  final MangaShort manga;
  final MangaRanobe data;

  const MangaActionsWidget({
    super.key,
    required this.manga,
    required this.data,
  });

  String getRateStatus(String value) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Читаю',
      'rewatching': 'Перечитываю',
      'completed': 'Прочитано',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? '';

    return status;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: TextButton(
                onPressed: null,
                child: Column(
                  children: const [
                    Icon(Icons.join_inner),
                    SizedBox(
                      height: 4,
                    ),
                    Text('Похожее'),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: null,
                child: Column(
                  children: const [
                    Icon(Icons.topic), //chat
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Обсуждение',
                      // style: TextStyle(
                      //   color: context.textTheme.bodyMedium?.color,
                      // ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: TextButton(
                onPressed: () {
                  _openFullscreenDialog(context);
                },
                child: Column(
                  children: const [
                    Icon(Icons.link),
                    SizedBox(
                      height: 4,
                    ),
                    Text('Ссылки'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreenDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      useSafeArea: false,
      builder: (context) => Dialog.fullscreen(
        child: MangaExternalLinksWidget(
          mangaId: manga.id!,
        ),
      ),
    );
  }
}

class MangaExternalLinksWidget extends ConsumerWidget {
  final int mangaId;

  const MangaExternalLinksWidget({super.key, required this.mangaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksMangaProvider(mangaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ссылки'),
        centerTitle: false,
        // automaticallyImplyLeading: false,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.close),
        //     onPressed: () => Navigator.of(context).pop(),
        //   ),
        // ],
      ),
      body: links.when(
        data: (data) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final link = data.toList()[index];
                  final enable = link.url != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(0),
                      child: ListTile(
                        enabled: enable,
                        title: Text(
                          link.kind?.replaceAll('_', ' ').capitalizeFirst ?? '',
                        ),
                        //subtitle: Text('${link.updatedAt}'),
                        trailing: const Icon(
                          Icons.open_in_browser,
                        ),
                        onTap: () {
                          launchUrlString(
                            link.url!,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        error: (err, stack) => CustomErrorWidget(err.toString(),
            () => ref.refresh(externalLinksMangaProvider(mangaId))),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
