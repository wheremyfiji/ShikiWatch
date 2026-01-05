import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../constants/config.dart';
import '../../../domain/models/animes.dart';
import '../../../domain/models/manga_short.dart';
import '../../../domain/models/shiki_character.dart';
import '../../../services/http/http_service_provider.dart';
import '../../../utils/app_utils.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../../utils/extensions/riverpod_extensions.dart';

import '../../widgets/anime_card.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/manga_card.dart';
import '../../widgets/title_description.dart';

final characterProvider =
    FutureProvider.autoDispose.family<ShikiCharacter, int>((ref, id) async {
  final dio = ref.read(httpServiceProvider);

  ref.cacheFor();

  final c = ref.cancelToken();

  final response = await dio.get(
    'characters/$id',
    cancelToken: c,
  );

  return ShikiCharacter.fromJson(response);
}, name: 'characterProvider');

class CharacterPage extends ConsumerWidget {
  final String characterId;

  const CharacterPage(this.characterId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(characterId);

    if (id == null || id == 0) {
      // так на всякий
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(characterId),
        ),
      );
    }

    final character = ref.watch(characterProvider(id));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              pinned: true,
              title: const Text('Персонаж'),
              actions: character.valueOrNull == null
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
                          ];
                        },
                        onSelected: (value) {
                          if (value == 0) {
                            launchUrlString(
                              '${AppConfig.staticUrl}${character.valueOrNull?.url ?? ''}',
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                    ],
            ),
            ...character.when(
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: CharacterHeader(data)
                        .animate()
                        .fade()
                        .slideY(begin: .05, end: 0, curve: Curves.easeOutCirc),
                  ),
                ),
                if (data.description != null &&
                    data.description!.isNotEmpty &&
                    data.descriptionHtml != null &&
                    data.descriptionHtml != '')
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: TitleDescriptionFromHtml(
                        data.descriptionHtml ?? '',
                        shouldExpand: !AppUtils.instance.isDesktop &&
                            data.descriptionHtml!.length > 600,
                      ).animate().fade(),
                    ),
                  ),
                // if (data.seyu != null && data.seyu!.isNotEmpty)
                //   SliverToBoxAdapter(
                //     child: CharacterSeyu(data.seyu!).animate().fade(),
                //   ),
                if (data.animes != null && data.animes!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: CharacterAnimes(data.animes!).animate().fade(),
                  ),
                if (data.mangas != null && data.mangas!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: CharacterMangas(data.mangas!).animate().fade(),
                  ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                ),
              ],
              error: (e, _) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    e.toString(),
                    () => ref.refresh(characterProvider(id)),
                  ),
                ),
              ],
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CharacterHeader extends StatelessWidget {
  final ShikiCharacter data;

  const CharacterHeader(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CachedCircleImage(
            AppConfig.staticUrl + (data.image?.original ?? ''),
            radius: 72,
            clipBehavior: Clip.antiAlias,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.name ?? '[Без имени]',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (data.russian != null && data.russian!.isNotEmpty)
                Text(
                  data.russian ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colorScheme.onBackground.withOpacity(0.8),
                  ),
                ),
              if (data.japanese != null && data.japanese!.isNotEmpty)
                Text(
                  data.japanese ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CharacterSeyu extends StatelessWidget {
  final List<Seyu> seyuList;

  const CharacterSeyu(this.seyuList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Сэйю',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: seyuList.length,
              itemBuilder: (context, index) {
                final isFirstItem = index == 0;
                final isLastItem = index == seyuList.length - 1;
                final seyu = seyuList[index];

                return Container(
                  margin: EdgeInsets.fromLTRB(
                    isFirstItem ? 16.0 : 0.0,
                    0.0,
                    isLastItem ? 16.0 : 8.0,
                    0.0,
                  ),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(8.0),
                    child: Column(
                      children: [
                        CachedCircleImage(
                          AppConfig.staticUrl + (seyu.image?.original ?? ''),
                          radius: 48,
                          clipBehavior: Clip.antiAlias,
                        ),
                        LimitedBox(
                          maxWidth: 100,
                          child: Text(
                            seyu.name ?? '[Без имени]',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterAnimes extends StatelessWidget {
  final List<Animes> animeList;

  const CharacterAnimes(this.animeList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Аниме',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 210,
            child: ListView.builder(
              addRepaintBoundaries: false,
              addSemanticIndexes: false,
              scrollDirection: Axis.horizontal,
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                final isFirstItem = index == 0;
                final isLastItem = index == animeList.length - 1;
                final anime = animeList[index];

                return Container(
                  margin: EdgeInsets.fromLTRB(
                    isFirstItem ? 16.0 : 0.0,
                    0.0,
                    isLastItem ? 16.0 : 8.0,
                    0.0,
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.55,
                    child: AnimeTileExp(anime),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterMangas extends StatelessWidget {
  final List<MangaShort> mangaList;

  const CharacterMangas(this.mangaList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Манга и ранобе',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 210,
            child: ListView.builder(
              addRepaintBoundaries: false,
              addSemanticIndexes: false,
              scrollDirection: Axis.horizontal,
              itemCount: mangaList.length,
              itemBuilder: (context, index) {
                final isFirstItem = index == 0;
                final isLastItem = index == mangaList.length - 1;
                final manga = mangaList[index];

                return Container(
                  margin: EdgeInsets.fromLTRB(
                    isFirstItem ? 16.0 : 0.0,
                    0.0,
                    isLastItem ? 16.0 : 8.0,
                    0.0,
                  ),
                  child: AspectRatio(
                    aspectRatio: 0.55,
                    child: MangaCardEx(manga),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
