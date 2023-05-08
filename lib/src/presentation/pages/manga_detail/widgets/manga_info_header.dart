import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:intl/intl.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/manga_short.dart';
import '../../../../utils/shiki_utils.dart';

class MangaInfoHeader extends StatelessWidget {
  final MangaShort data;

  const MangaInfoHeader({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const double height = 350;

    DateFormat format = DateFormat("yyyy-MM-dd");
    final airedDateTime = format.parse(data.airedOn ?? '');
    final airedString = DateFormat.yMMM().format(airedDateTime);
    final releasedDateTime = format.parse(data.releasedOn ?? '1970-01-01');
    final releasedString = DateFormat.yMMM().format(releasedDateTime);

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
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      ExtendedImage.network(
                        AppConfig.staticUrl +
                            (data.image?.original ?? data.image?.preview ?? ''),
                        height: height - 150,
                        width: 145,
                        fit: BoxFit.cover,
                        cache: true,
                      ),
                      // if (favoured) ...[
                      //   const Padding(
                      //     padding: EdgeInsets.all(8.0),
                      //     child: Icon(
                      //       Icons.star,
                      //       color: Colors.yellow,
                      //     ),
                      //   ),
                      // ],
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
                      Text(
                        (data.russian == '' ? data.name : data.russian) ?? '',
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
                      Text(
                        '${getKind(data.kind!)} • ${getStatus(data.status!)}',
                        textAlign: TextAlign.start,
                      ),
                      if (data.status == 'ongoing') ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Выходит с $airedString',
                          textAlign: TextAlign.start,
                        ),
                      ],
                      if (data.status == 'released') ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          data.releasedOn == null
                              ? 'Издано в $airedString'
                              : 'Издано в $releasedString',
                          textAlign: TextAlign.start,
                        ),
                      ],
                      if (data.volumes != null &&
                          data.volumes != 1 &&
                          data.volumes != 0) ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Тома: ${data.volumes}',
                          textAlign: TextAlign.start,
                        ),
                      ],
                      if (data.volumes != null && data.volumes != 0) ...[
                        const SizedBox(
                          height: 2,
                        ),
                        Text(
                          'Главы: ${data.chapters}',
                          textAlign: TextAlign.start,
                        ),
                      ],
                      // const SizedBox(
                      //   height: 2,
                      // ),
                      // Text(
                      //   'airedOn: ${data.airedOn}',
                      //   textAlign: TextAlign.start,
                      // ),
                      // Text(
                      //   'releasedOn: ${data.releasedOn}',
                      //   textAlign: TextAlign.start,
                      // ),
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
