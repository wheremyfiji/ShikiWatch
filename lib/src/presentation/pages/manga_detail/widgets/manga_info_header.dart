import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/manga_short.dart';
import '../../../../utils/shiki_utils.dart';
import '../../../providers/manga_details_provider.dart';
import '../../../widgets/cached_image.dart';

class MangaInfoHeader extends StatelessWidget {
  final MangaShort data;

  const MangaInfoHeader({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    final airedDateTime = format.parse(data.airedOn ?? '');
    final airedString = DateFormat.yMMM().format(airedDateTime);
    final releasedDateTime = format.parse(data.releasedOn ?? '1970-01-01');
    final releasedString = DateFormat.yMMM().format(releasedDateTime);

    final location = GoRouter.of(context).location;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Positioned.fill(
          child: CachedImage(
            AppConfig.staticUrl +
                (data.image?.original ?? data.image?.preview ?? ''),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          color: Theme.of(context).colorScheme.background.withOpacity(0.9),
          alignment: Alignment.center,
        ),
        Positioned.fill(
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.background,
                  Colors.transparent
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 16,
          right: 1,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => context.pushTransparentRoute(
                      ImageViewerPage(
                        AppConfig.staticUrl +
                            (data.image?.original ?? data.image?.preview ?? ''),
                        tag: AppConfig.staticUrl +
                            (data.image?.original ??
                                data.image?.preview ??
                                '') +
                            location,
                      ),
                      rootNavigator: true,
                    ),
                    child: Hero(
                      tag: AppConfig.staticUrl +
                          (data.image?.original ?? data.image?.preview ?? '') +
                          location,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 220,
                          child: AspectRatio(
                            aspectRatio: 0.703,
                            child: CachedImage(
                              AppConfig.staticUrl +
                                  (data.image?.original ??
                                      data.image?.preview ??
                                      ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
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
              const SizedBox(
                width: 16.0,
              ),
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
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  fontSize: 12, fontWeight: FontWeight.normal),
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
