//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
//import 'package:transparent_image/transparent_image.dart';

import '../../constants/config.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../utils/shiki_utils.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          shadowColor: Colors.transparent,
          child: Tooltip(
            waitDuration: TargetP.instance.isDesktop
                ? const Duration(seconds: 1)
                : const Duration(milliseconds: 0),
            message: 'Изменено: $updateString\nСоздано: $createString',
            child: InkWell(
              onTap: () {
                FocusScope.of(context).unfocus();
                context.pushNamed(
                  'library_anime',
                  params: <String, String>{
                    'id': (data.anime?.id!).toString(),
                  },
                  extra: data.anime,
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
                                '${data.episodes.toString()} из ${data.anime?.episodes.toString()} эп.',
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
                                '${data.episodes.toString()} / ${data.anime?.episodesAired.toString()} из ${data.anime?.episodes.toString()} эп.',
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
          ),
        );
      },
    );
  }
}

class AnimeTileExp extends StatelessWidget {
  final Animes data;

  const AnimeTileExp(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     SizedBox(
    //       height: MediaQuery.of(context).size.height / 1.4,
    //       child: ClipRRect(
    //         clipBehavior: Clip.hardEdge,
    //         borderRadius: BorderRadius.circular(12.0),
    //         child: CachedNetworkImage(
    //           imageUrl: AppConfig.staticUrl + (data.image?.original ?? ''),
    //           placeholder: (context, url) {
    //             return Shimmer.fromColors(
    //               baseColor: Theme.of(context).colorScheme.surface,
    //               highlightColor:
    //                   Theme.of(context).colorScheme.onInverseSurface,
    //               child: Container(
    //                 color: Colors.black,
    //               ),
    //             );
    //           },
    //           errorWidget: (context, url, error) => const Icon(Icons.error),
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //     ),
    //     Expanded(
    //       child: Text(
    //         (data.russian == '' ? data.name : data.russian) ?? '',
    //         maxLines: 2,
    //         overflow: TextOverflow.ellipsis,
    //         style: const TextStyle(
    //           fontSize: 12.0,
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //     ),
    //   ],
    // );

    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          onTap: () => context.push('/explore/${data.id!}', extra: data),
          child: Column(
            //mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight / 1.4,
                child:
                    // Container(
                    //   color: Colors.red,
                    //   alignment: Alignment.bottomRight,
                    //   child: const Text('asa'),
                    // )
                    //     ExtendedImage.network(
                    //   AppConfig.staticUrl + (data.image?.preview ?? ''),
                    //   fit: BoxFit.cover,
                    //   enableLoadState: false,
                    //   excludeFromSemantics: true,
                    //   clipBehavior: Clip.none,
                    //   clearMemoryCacheWhenDispose: true,
                    //   //enableMemoryCache: false,
                    //   filterQuality: FilterQuality.low,
                    //   //compressionRatio: 0.6,
                    //   //cacheWidth: 200,
                    //   // loadStateChanged: (ExtendedImageState state) {
                    //   //   switch (state.extendedImageLoadState) {
                    //   //     case LoadState.loading:
                    //   //       return Shimmer.fromColors(
                    //   //         baseColor: Theme.of(context).colorScheme.surface,
                    //   //         highlightColor:
                    //   //             Theme.of(context).colorScheme.onInverseSurface,
                    //   //         child: Container(
                    //   //           color: Colors.black,
                    //   //         ),
                    //   //       );
                    //   //     case LoadState.completed:
                    //   //       return state.completedWidget;
                    //   //     case LoadState.failed:
                    //   //       return const Icon(Icons.error);
                    //   //   }
                    //   // },
                    // ),

                    ClipRRect(
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
                  //mainAxisSize: MainAxisSize.min,
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
                      //mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${getKind(data.kind ?? '')} • ${data.score}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                        ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        return Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          shadowColor: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/explore/${data.id!}', extra: data),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight / 1.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child:
                        // FadeInImage.memoryNetwork(
                        //   fadeInDuration: const Duration(milliseconds: 300),
                        //   fit: BoxFit.cover,
                        //   placeholder: kTransparentImage,
                        //   image: AppConfig.staticUrl + (data.image?.original ?? ''),
                        // ),
                        ImageWithShimmerWidget(
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
                            '${getKind(data.kind ?? '')} • ${data.score}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  Theme.of(context).textTheme.bodySmall!.color,
                            ),
                          ),
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
          ),
        );
      },
    );
  }
}
