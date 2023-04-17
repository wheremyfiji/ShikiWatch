import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/animes.dart';
import '../../../../utils/shiki_utils.dart';

class AnimeInfoHeader extends StatelessWidget {
  final Animes data;
  final int duration;
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
                  border: Border.all(width: 0, color: Colors.transparent),
                  image: DecorationImage(
                    filterQuality: FilterQuality.low,
                    image: ExtendedNetworkImageProvider(
                      AppConfig.staticUrl +
                          (data.image?.original ?? data.image?.preview ?? ''),
                      cache: true,
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Container(
              height: height,
              color: Theme.of(context).colorScheme.background.withOpacity(0.9),
              alignment: Alignment.center),
          Positioned(
            bottom: -1,
            child: Container(
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
          ),
          Positioned(
            bottom: 20,
            right: 1,
            left: 1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                // Hero(
                //   tag: data.id ?? 0,
                //   child:
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      //Hero(
                      //  tag: data.id ?? 0,
                      //  child:
                      ExtendedImage.network(
                        AppConfig.staticUrl +
                            (data.image?.original ?? data.image?.preview ?? ''),
                        height: height - 150,
                        width: 145,
                        fit: BoxFit.cover,
                        cache: true,
                      ),
                      //),
                      if (favoured) ...[
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.favorite,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                //),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        data.russian ??
                            data.name ??
                            //model.names!.en ??
                            '[Без навзвания]',
                        maxLines: 3,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (data.name != null) ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          data.name!,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(fontWeight: FontWeight.normal),
                        ),
                      ],
                      const SizedBox(
                        height: 8,
                      ),
                      Text('$year • $season', textAlign: TextAlign.start),
                      const SizedBox(
                        height: 2,
                      ),
                      Text(
                          //'${getStatus(data.status!)} • ${getKind(data.kind!)} • $rating • ${data.score}\u2b50', //★ U+2B50	⭐
                          '${getStatus(data.status!)} • ${getKind(data.kind!)} • $rating',
                          textAlign: TextAlign.start),
                      const SizedBox(
                        height: 2,
                      ),

                      if (data.episodes != null && data.episodesAired != null
                      //&&
                      //data.duration != null
                      )
                        data.status == 'released'
                            ? Text(
                                '${data.episodes!} эп. по ~$duration мин.',
                                textAlign: TextAlign.start,
                              )
                            : Text(
                                '${data.episodesAired!} из ${data.episodes! == 0 ? '?' : '${data.episodes!}'} эп. по ~$duration мин.',
                                textAlign: TextAlign.start,
                              ),
                      const SizedBox(
                        height: 2,
                      ),
                      //Text('Оценка: ${data.score}', textAlign: TextAlign.start),
                      //AppDimens.sizedBoxH5,
                      // const SizedBox(
                      //   height: 4,
                      // ),
                      // const Text('Статус: Приходит',
                      //     textAlign: TextAlign.start),
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
}
