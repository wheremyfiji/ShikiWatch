import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/animes.dart';
import '../../../../utils/shiki_utils.dart';
import '../../../providers/anime_details_provider.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/show_pop_up.dart';

class AnimeInfoHeader extends StatelessWidget {
  final Animes data;
  final String duration;
  final bool favoured;
  final String nextEp;
  final String rating;

  const AnimeInfoHeader({
    super.key,
    required this.data,
    required this.duration,
    required this.favoured,
    required this.nextEp,
    required this.rating,
  });

  List<String> getDate(String? airedOn, String? releasedOn) {
    //String? date = releasedOn ?? airedOn;
    String? date = airedOn;

    if (date == null) {
      return ['n/d', ''];
    }

    final splitted = date.split('-');
    var month = int.parse(splitted[1]);

    return [splitted[0], getSeason(month)];
  }

  @override
  Widget build(BuildContext context) {
    final date = getDate(data.airedOn, data.releasedOn);
    final year = date[0];
    final season = date[1];
    const double height = 350;
    return Center(
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                height: height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    filterQuality: FilterQuality.low,
                    image: CachedNetworkImageProvider(
                      AppConfig.staticUrl +
                          (data.image?.original ?? data.image?.preview ?? ''),
                      cacheManager: cacheManager,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.background.withOpacity(0.9),
            alignment: Alignment.center,
          ),
          Container(
            height: height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.background,
                  Colors.transparent
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0, 1],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 1,
            left: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      GestureDetector(
                        onTap: () => showSlideUp(
                          context,
                          ImageViewer(
                            AppConfig.staticUrl +
                                (data.image?.original ??
                                    data.image?.preview ??
                                    ''),
                            cached: true,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: AppConfig.staticUrl +
                              (data.image?.original ??
                                  data.image?.preview ??
                                  ''),
                          height: height - 150,
                          width: 145,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (favoured) ...[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.star,
                            color: Colors.yellow,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => _showSheet(context),
                        child: Text(
                          (data.russian == '' ? data.name : data.russian) ?? '',
                          maxLines: 3,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (data.name != null) ...[
                        const SizedBox(
                          height: 2,
                        ),
                        GestureDetector(
                          onTap: () => _showSheet(context),
                          child: Text(
                            data.name!,
                            maxLines: 2,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                      ],
                      const SizedBox(
                        height: 8,
                      ),
                      Text('$year • $season', textAlign: TextAlign.start),
                      Text(
                        '${getKind(data.kind!)} • ${getStatus(data.status!)}', // • $rating
                        textAlign: TextAlign.start,
                      ),
                      if (data.episodes != null && data.episodesAired != null)
                        data.status == 'released'
                            ? Text(
                                '${data.episodes!} эп. по ~$duration мин.',
                                textAlign: TextAlign.start,
                              )
                            : Text(
                                '${data.episodesAired!} из ${data.episodes! == 0 ? '?' : '${data.episodes!}'} эп. по ~$duration мин.',
                                textAlign: TextAlign.start,
                              ),
                      nextEp != ''
                          ? Text('След. серия в $nextEp',
                              textAlign: TextAlign.start)
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _showSheet(BuildContext c) {
    showModalBottomSheet<void>(
      context: c,
      builder: (context) => AnimeOtherNames(data.id!),
      useRootNavigator: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(c).size.width >= 700 ? 700 : double.infinity,
      ),
    );
  }
}

class AnimeOtherNames extends ConsumerWidget {
  final int animeId;

  const AnimeOtherNames(this.animeId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anime = ref
        .watch(titleInfoPageProvider(animeId))
        .title
        .whenOrNull(data: (data) => data);

    if (anime == null) {
      return const SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (anime.english != null && anime.english!.isNotEmpty) ...[
              const Text(
                'English',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              ...List.generate(anime.english!.length,
                  ((index) => SelectableText(anime.english![index]))),
              const Divider(),
            ],
            if (anime.japanese != null && anime.japanese!.isNotEmpty) ...[
              const Text(
                'Japanese',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              ...List.generate(anime.japanese!.length,
                  ((index) => SelectableText(anime.japanese![index]))),
            ],
            if (anime.synonyms != null && anime.synonyms!.isNotEmpty) ...[
              const Divider(),
              const Text(
                'Синонимы',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 2,
              ),
              ...List.generate(anime.synonyms!.length,
                  ((index) => SelectableText(anime.synonyms![index]))),
            ],
          ],
        ),
      ),
    );
  }
}
