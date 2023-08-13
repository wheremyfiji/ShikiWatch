import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/config.dart';
import '../../../domain/models/animes.dart';
import '../../../domain/models/manga_short.dart';
import '../../../domain/models/shiki_character.dart';
import '../../../services/http/http_service_provider.dart';
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
            ),
            ...character.when(
              data: (data) => [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: CharacterHeader(data),
                ),
                if (data.description != null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverToBoxAdapter(
                      child: TitleDescription(data.descriptionHtml ?? ''),
                    ),
                  ),
                if (data.seyu != null && data.seyu!.isNotEmpty)
                  SliverToBoxAdapter(child: CharacterSeyu(data.seyu!)),
                if (data.animes != null && data.animes!.isNotEmpty)
                  SliverToBoxAdapter(child: CharacterAnimes(data.animes!)),
                if (data.mangas != null && data.mangas!.isNotEmpty)
                  SliverToBoxAdapter(child: CharacterMangas(data.mangas!)),
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
    return SliverToBoxAdapter(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: CachedNetworkImageProvider(
                AppConfig.staticUrl + (data.image?.original ?? ''),
                cacheManager: cacheManager,
              ),
              radius: 72,
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
                    maxLines: 2,
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
      ),
    );
  }
}

class CharacterSeyu extends StatelessWidget {
  final List<Seyu> seyuList;

  const CharacterSeyu(this.seyuList, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: seyuList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final seyu = seyuList[index];

                return Column(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      backgroundImage: CachedNetworkImageProvider(
                        AppConfig.staticUrl + (seyu.image?.original ?? ''),
                        cacheManager: cacheManager,
                      ),
                      radius: 48,
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
            child: ListView.separated(
              addRepaintBoundaries: false,
              addSemanticIndexes: false,
              scrollDirection: Axis.horizontal,
              itemCount: animeList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final anime = animeList[index];

                return AspectRatio(
                  aspectRatio: 0.55,
                  child: AnimeTileExp(anime),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
            child: ListView.separated(
              addRepaintBoundaries: false,
              addSemanticIndexes: false,
              scrollDirection: Axis.horizontal,
              itemCount: mangaList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final manga = mangaList[index];

                return AspectRatio(
                  aspectRatio: 0.55,
                  child: MangaCardEx(manga),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
