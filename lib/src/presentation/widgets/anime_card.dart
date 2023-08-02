import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../pages/anime_details/widgets/user_anime_rate.dart';
import '../../domain/models/user_anime_rates.dart';
import 'custom_linear_progress_indicator.dart';
import '../../domain/models/pages_extra.dart';
import '../widgets/image_with_shimmer.dart';
import '../../domain/models/animes.dart';
import '../../utils/shiki_utils.dart';
import '../../constants/config.dart';

class AnimeListTile extends StatelessWidget {
  final UserAnimeRates data;

  const AnimeListTile(this.data, {super.key});

  List<String>? getDate(String? airedOn) {
    String? date = airedOn;

    if (date == null) {
      return null;
    }

    final splitted = date.split('-');
    var month = int.parse(splitted[1]);

    return [splitted[0], getSeason(month)];
  }

  @override
  Widget build(BuildContext context) {
    final epCount = data.anime?.status == 'released'
        ? data.anime?.episodes
        : data.anime?.episodesAired;

    final releasedOnDateTime =
        DateTime.parse(data.anime!.releasedOn ?? '1917-10-25').toLocal();
    final releasedOn = DateFormat('yyyy').format(releasedOnDateTime);

    final airedOnDateTime =
        DateTime.parse(data.anime!.airedOn ?? '1917-10-25').toLocal();
    final airedOn = DateFormat('yyyy-MM-dd').format(airedOnDateTime);

    final date = getDate(data.anime?.airedOn);
    final year = date?[0];
    final season = date?[1];

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Colors.transparent,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onLongPress: () {
          FocusScope.of(context).unfocus();

          final t = data.toAnime;

          showModalBottomSheet<void>(
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
                  data: t,
                  needUpdate: false,
                  //anime: animeData,
                ),
              );
            },
          );
        },
        onTap: () {
          FocusScope.of(context).unfocus();

          final extra = AnimeDetailsPageExtra(
            id: data.anime!.id!,
            label: (data.anime!.russian == ''
                    ? data.anime!.name
                    : data.anime!.russian) ??
                '',
          );

          context.pushNamed(
            'library_anime',
            pathParameters: <String, String>{
              'id': (data.anime?.id!).toString(),
            },
            extra: extra,
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              child: AspectRatio(
                aspectRatio: 0.703,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ImageWithShimmerWidget(
                    imageUrl: AppConfig.staticUrl +
                        (data.anime?.image?.original ?? ''),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (data.anime?.russian == ''
                            ? data.anime?.name
                            : data.anime?.russian) ??
                        '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        data.anime?.status == 'released'
                            ? '${releasedOn != '1917' ? releasedOn : airedOn.split('-')[0]} • '
                            : '${getStatus(data.anime?.status ?? '')} • ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                      Text(
                        data.anime?.episodes == 0
                            ? getKind(data.anime?.kind ?? '')
                            : '${getKind(data.anime?.kind ?? '')} • ${data.anime?.episodes} эп.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      ),
                      if (data.anime?.score != '0.0') ...[
                        Text(
                          ' • ${data.anime?.score}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 2),
                          child: Icon(
                            Icons.star_rounded,
                            size: 10,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (data.anime?.status != 'anons') ...[
                    if (epCount != null && epCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 2),
                        child: CustomLinearProgressIndicator(
                          value: data.episodes ?? 0,
                          maxValue: epCount,
                        ),
                      ),
                    Text(
                      '${data.episodes.toString()} из $epCount эп.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                  ],
                  if (data.anime?.status == 'anons' &&
                      data.anime!.airedOn != null &&
                      data.anime!.airedOn!.isNotEmpty)
                    Text(
                      //'Выйдет $airedOn',
                      '$season $year',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall!.color,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimeCard extends StatelessWidget {
  final UserAnimeRates data;

  const AnimeCard(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //final createDT = DateTime.parse(data.createdAt!).toLocal();
    //final updateDT = DateTime.parse(data.updatedAt!).toLocal();
    //final createString = DateFormat('yyyy-MM-dd в HH:mm').format(createDT);
    //final updateString = DateFormat('yyyy-MM-dd в HH:mm').format(updateDT);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          borderRadius: BorderRadius.circular(12),
          color: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            // splashColor: Colors.transparent,
            // highlightColor: Colors.transparent,
            // splashFactory: NoSplash.splashFactory,
            onLongPress: () {
              FocusScope.of(context).unfocus();

              final t = data.toAnime;

              showModalBottomSheet<void>(
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
                      data: t,
                      needUpdate: false,
                    ),
                  );
                },
              );
            },
            onTap: () {
              FocusScope.of(context).unfocus();

              final extra = AnimeDetailsPageExtra(
                id: data.anime!.id!,
                label: (data.anime!.russian == ''
                        ? data.anime!.name
                        : data.anime!.russian) ??
                    '',
              );

              context.pushNamed(
                'library_anime',
                pathParameters: <String, String>{
                  'id': (data.anime?.id!).toString(),
                },
                extra: extra,
              );
            },
            child: Column(
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight / 1.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: ImageWithShimmerWidget(
                      imageUrl: AppConfig.staticUrl +
                          (data.anime?.image?.original ?? ''),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                SizedBox(
                  width: constraints.maxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (data.anime?.russian == ''
                                ? data.anime?.name
                                : data.anime?.russian) ??
                            '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      data.anime?.status == 'released'
                          ? Text(
                              '${data.episodes.toString()} из ${data.anime?.episodes! == 0 ? '?' : '${data.anime?.episodes!}'} эп.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                            )
                          : Text(
                              '${data.episodes.toString()} / ${data.anime?.episodesAired.toString()} из ${data.anime?.episodes! == 0 ? '?' : '${data.anime?.episodes!}'} эп.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .color,
                              ),
                            ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class AnimeTileExp extends StatelessWidget {
  final Animes data;
  final bool showScore;

  const AnimeTileExp(
    this.data, {
    Key? key,
    this.showScore = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          //onTap: () => context.push('/explore/${data.id!}', extra: data),
          onTap: () {
            final extra = AnimeDetailsPageExtra(
              id: data.id!,
              label: (data.russian == '' ? data.name : data.russian) ?? '',
            );

            context.push('/explore/${data.id!}', extra: extra);
          },
          child: Column(
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight / 1.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: ImageWithShimmerWidget(
                    imageUrl:
                        AppConfig.staticUrl + (data.image?.original ?? ''),
                  ),
                ),
              ),
              const SizedBox(
                height: 4,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (data.russian == '' ? data.name : data.russian) ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          showScore
                              ? '${getKind(data.kind ?? '')} • ${data.score}'
                              : getKind(data.kind ?? ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
                        if (showScore)
                          const Icon(
                            Icons.star_rounded,
                            size: 10,
                          ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
