//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../constants/config.dart';
import '../../domain/models/manga_short.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../utils/shiki_utils.dart';
import '../../utils/app_utils.dart';
import '../widgets/image_with_shimmer.dart';

class MangaCard extends StatelessWidget {
  final UserAnimeRates data;

  const MangaCard(
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
        return Tooltip(
          waitDuration: AppUtils.instance.isDesktop
              ? const Duration(seconds: 1)
              : const Duration(milliseconds: 0),
          message: 'Изменено: $updateString\nСоздано: $createString',
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            onTap: () {
              FocusScope.of(context).unfocus();
              context.pushNamed(
                'library_manga',
                pathParameters: <String, String>{
                  'id': (data.manga?.id!).toString(),
                },
                extra: data.manga,
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
                          (data.manga?.image?.original ?? ''),
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
                        (data.manga?.russian == ''
                                ? data.manga?.name
                                : data.manga?.russian) ??
                            '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        getKind(data.manga?.kind ?? ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall!.color,
                        ),
                      )
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

class MangaCardEx extends StatelessWidget {
  final MangaShort data;

  const MangaCardEx(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          onTap: () => context.pushNamed(
            'library_manga',
            pathParameters: <String, String>{
              'id': (data.id!).toString(),
            },
            extra: data,
          ),
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
  }
}
