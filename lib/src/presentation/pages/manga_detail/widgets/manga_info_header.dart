import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/manga_short.dart';
import '../../../../utils/shiki_utils.dart';
import '../../../providers/manga_details_provider.dart';
import '../../../widgets/cached_image.dart';
import '../../../widgets/show_pop_up.dart';

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
            height: height,
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
                          cacheManager: cacheManager,
                        ),
                      ),
                      // ExtendedImage.network(
                      //   AppConfig.staticUrl +
                      //       (data.image?.original ?? data.image?.preview ?? ''),
                      //   height: height - 150,
                      //   width: 145,
                      //   fit: BoxFit.cover,
                      //   cache: true,
                      // ),
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

  _showSheet(BuildContext c) {
    showModalBottomSheet<void>(
      context: c,
      builder: (context) => MangaOtherNames(data.id!),
      useRootNavigator: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(c).size.width >= 700 ? 700 : double.infinity,
      ),
    );
  }
}

class MangaOtherNames extends ConsumerWidget {
  final int mangaId;

  const MangaOtherNames(this.mangaId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manga = ref
        .watch(mangaDetailsPageProvider(mangaId))
        .title
        .whenOrNull(data: (data) => data);

    if (manga == null) {
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
            if (manga.english != null && manga.english!.isNotEmpty) ...[
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
              ...List.generate(manga.english!.length,
                  ((index) => SelectableText(manga.english![index]))),
              const Divider(),
            ],
            if (manga.japanese != null && manga.japanese!.isNotEmpty) ...[
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
              ...List.generate(manga.japanese!.length,
                  ((index) => SelectableText(manga.japanese![index]))),
            ],
            if (manga.synonyms != null && manga.synonyms!.isNotEmpty) ...[
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
              ...List.generate(manga.synonyms!.length,
                  ((index) => SelectableText(manga.synonyms![index]))),
            ],
          ],
        ),
      ),
    );
  }
}
