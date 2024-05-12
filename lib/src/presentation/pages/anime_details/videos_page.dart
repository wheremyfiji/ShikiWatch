import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';

import '../../../services/http/http_service_provider.dart';
import '../../../utils/extensions/riverpod_extensions.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';

class AnimeVideosPage extends ConsumerWidget {
  final int id;
  final String name;

  const AnimeVideosPage({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videos = ref.watch(animeVideosProvider(id));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Видео',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.theme.colorScheme.onBackground
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ...videos.when(
              data: (data) {
                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 380.0, // 440 ?? 340
                        childAspectRatio: 16 / 9,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemBuilder: (context, index) => VideoCard(data[index]),
                      itemCount: data.length,
                    ),
                  ),
                  // SliverList.builder(
                  //   itemCount: data.length,
                  //   itemBuilder: (context, index) {
                  //     final item = data[index];

                  //     return Padding(
                  //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //       child: VideoCard(item),
                  //     );

                  //     return ListTile(
                  //       visualDensity: VisualDensity.compact,
                  //       //onTap: () {},
                  //       onTap: () => launchUrlString(
                  //         item.url,
                  //         mode: LaunchMode.externalApplication,
                  //       ),
                  //       leading: SizedBox(
                  //         height: 48,
                  //         child: AspectRatio(
                  //           aspectRatio: 16 / 9,
                  //           child: Container(
                  //             clipBehavior: Clip.antiAlias,
                  //             decoration: BoxDecoration(
                  //               color: Colors.black,
                  //               borderRadius: BorderRadius.circular(8),
                  //             ),
                  //             child: CachedImage(
                  //               item.imageUrl,
                  //               fit: BoxFit.cover,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       title: Text(
                  //         item.name ?? '',
                  //         maxLines: 2,
                  //         overflow: TextOverflow.ellipsis,
                  //         style: TextStyle(
                  //           color: context.colorScheme.onBackground,
                  //           // fontSize: 14,
                  //           height: 1.2,
                  //         ),
                  //       ),
                  //       subtitle: Text(
                  //         item.kind.rusName,
                  //         style: TextStyle(
                  //           //fontSize: 12,
                  //           color: context.colorScheme.onBackground
                  //               .withOpacity(0.8),
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    err.toString(),
                    () => ref.refresh(animeVideosProvider(id)),
                  ),
                ),
              ],
            ),
            SliverPadding(
              padding: EdgeInsets.only(
                bottom: context.padding.bottom + 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  const VideoCard(this.item, {super.key});

  final AnimeVideo item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        return DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(
              color: context.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Stack(
              children: [
                Positioned.fill(
                  // top: -1,
                  // left: -1,
                  // right: -1,
                  // bottom: -1,
                  child: CachedImage(item.imageUrl),
                ),
                Positioned.fill(
                  top: -1,
                  bottom: -1,
                  left: -1,
                  right: -1,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            context.theme.scaffoldBackgroundColor
                                .withOpacity(0),
                            context.theme.scaffoldBackgroundColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // if (item.hosting != null)
                        //   Text(
                        //     item.hosting!,
                        //     style: context.textTheme.bodySmall,
                        //   ),
                        Text(
                          item.kind.rusName,
                          style: context.textTheme.bodySmall?.copyWith(
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(
                          height: 2.0,
                        ),
                        Text(
                          (item.name == null || item.name!.isEmpty)
                              ? '[Без нзвания]'
                              : item.name!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyLarge?.copyWith(
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  child: SizedBox(
                    height: boxConstraints.maxHeight,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          // onTap: () {
                          //   print('url: ${item.url}');
                          // },
                          onTap: () => launchUrlString(
                            item.url,
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

final animeVideosProvider =
    FutureProvider.autoDispose.family<List<AnimeVideo>, int>((ref, id) async {
  final dio = ref.read(httpServiceProvider);
  final cancelToken = ref.cancelToken();

  final response = await dio.get(
    'animes/$id/videos',
    cancelToken: cancelToken,
  );

  final list = <AnimeVideo>[
    for (final e in response) AnimeVideo.fromJson(e),
  ];

  //list.sortBy<num>((e) => e.kind.index);

  final sortedList = list.sortedBy<num>((e) => e.kind.index);

  return sortedList;
}, name: 'animeVideosProvider');

class AnimeVideo {
  int id;
  String url;
  String imageUrl;
  String playerUrl;
  String? name;
  AnimeVideoKind kind;
  String? hosting;

  AnimeVideo({
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.playerUrl,
    this.name,
    required this.kind,
    this.hosting,
  });

  factory AnimeVideo.fromJson(Map<String, dynamic> json) {
    final url = (json["url"] as String).replaceFirst('http://', 'https://');
    final imageUrl =
        (json["image_url"] as String).replaceFirst('http://', 'https://');
    final playerUrl =
        (json["player_url"] as String).replaceFirst('http://', 'https://');

    return AnimeVideo(
      id: json["id"],
      url: url,
      imageUrl: imageUrl,
      playerUrl: playerUrl,
      name: json["name"],
      kind: AnimeVideoKind.fromValue(json["kind"]),
      hosting: json["hosting"],
    );
  }
}

enum AnimeVideoKind {
  op('op'),
  ed('ed'),
  episodePreview('episode_preview'),
  pv('pv'),
  opEdClip('op_ed_clip'),
  clip('clip'),
  characterTrailer('character_trailer'),
  cm('cm'),
  other('other');

  final String value;

  const AnimeVideoKind(this.value);

  static AnimeVideoKind fromValue(String value) =>
      AnimeVideoKind.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      AnimeVideoKind.pv => 'Промо',
      AnimeVideoKind.characterTrailer => 'Трейлер персонажа',
      AnimeVideoKind.cm => 'Реклама',
      AnimeVideoKind.op => 'Опенинг',
      AnimeVideoKind.ed => 'Эндинг',
      AnimeVideoKind.opEdClip => 'Муз. клип',
      AnimeVideoKind.clip => 'Клип',
      AnimeVideoKind.other => 'Другое',
      AnimeVideoKind.episodePreview => 'Превью эпизода',
    };
  }
}
