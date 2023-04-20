//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../constants/config.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../utils/target_platform.dart';
import '../widgets/image_with_shimmer.dart';

class AnimeCard extends StatelessWidget {
  final UserAnimeRates data;

  const AnimeCard(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createDT = DateTime.parse(data.createdAt!).toLocal();
    final updateDT = DateTime.parse(data.updatedAt!).toLocal();
    final createString = DateFormat('yyyy-MM-dd в HH:mm').format(createDT);
    final updateString = DateFormat('yyyy-MM-dd в HH:mm').format(updateDT);
    return Material(
      surfaceTintColor: Colors.transparent,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.transparent,
      child: Tooltip(
        //showDuration: const Duration(seconds: 2),
        waitDuration: TargetP.instance.isDesktop
            ? const Duration(seconds: 1)
            : const Duration(milliseconds: 0),
        message: 'Изменено: $updateString\nСоздано: $createString',
        child: InkWell(
          onTap: () {
            FocusScope.of(context).unfocus();
            context.push('/library/${data.anime?.id!}', extra: data.anime);
            //context.push('/library/${data.anime?.id!}', extra: data);
          },
          //onLongPress: () => log('onLongPress'),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            //mainAxisSize: MainAxisSize.min,
            children: [
              //Hero(
              //  tag: data.anime?.id ?? 0,
              //  child:
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ImageWithShimmerWidget(
                  imageUrl:
                      AppConfig.staticUrl + (data.anime?.image?.original ?? ''),
                  width: 120,
                  height: 150,
                ),
              ),
              //),
              Padding(
                //padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    //FittedBox(
                    //  child:
                    Text(
                      data.anime?.russian ?? data.anime?.name ?? '',
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      //style: Theme.of(context).textTheme.titleSmall,
                      style: const TextStyle(
                        //letterSpacing: 0.0,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    //),
                    const SizedBox(height: 4),

                    data.anime?.status == 'released'
                        ? Text(
                            //'${data.episodes.toString()} / ${data.anime?.episodes.toString()} эп, Вышло',
                            //'${data.anime?.episodes.toString()} эп / Вышло',
                            '${data.episodes.toString()} из ${data.anime?.episodes.toString()} эп.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          )
                        : Text(
                            //'${data.anime?.episodesAired.toString()} из ${data.anime?.episodes.toString()} эп / Выходит',
                            '${data.episodes.toString()} / ${data.anime?.episodesAired.toString()} из ${data.anime?.episodes.toString()} эп.',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),

                    // Text(
                    //   '8 из 12 эп, Выходит',
                    //   //.toUpperCase(),
                    //   maxLines: 1,
                    //   overflow: TextOverflow.ellipsis,
                    //   textAlign: TextAlign.center,
                    //   style: TextStyle(
                    //     fontSize: 10,
                    //     color: Theme.of(context).textTheme.bodySmall!.color,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimeCard2 extends StatelessWidget {
  const AnimeCard2({
    Key? key,
    // this.height = 360,
    // this.width = 240,
    this.height = 200,
    this.width = 100,
  }) : super(key: key);

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  //FittedBox(
                  //  child:
                  const Text(
                    'Ложные выводы 2 Ложные выводы 2 Ложные выводы 2 Ложные выводы 2 Ложные выводы 2 Ложные выводы 2',
                    maxLines: 2,
                    //textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    //style: Theme.of(context).textTheme.titleSmall,
                    style: TextStyle(
                      //letterSpacing: 0.0,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  //),
                  const SizedBox(height: 5),
                  //FittedBox(
                  //  child:
                  Text(
                    //"EP ${anime.totalEpisodes ?? "?"}, ${anime.status ?? ""}"
                    '8 из 12 эп, Выходит',
                    //.toUpperCase(),
                    maxLines: 1,
                    //textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                    // style: Theme.of(context)
                    //     .textTheme
                    //     .labelSmall
                    //     ?.copyWith(fontWeight: FontWeight.w300),
                  ),
                  //),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
