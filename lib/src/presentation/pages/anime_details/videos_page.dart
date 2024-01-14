import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
                  SliverList.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];

                      return ListTile(
                        visualDensity: VisualDensity.compact,
                        //onTap: () {},
                        onTap: () => launchUrlString(
                          item.url,
                          mode: LaunchMode.externalApplication,
                        ),
                        leading: SizedBox(
                          height: 48,
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Container(
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CachedImage(
                                item.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          item.name ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colorScheme.onBackground,
                            // fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        subtitle: Text(
                          item.kind.rusName,
                          style: TextStyle(
                            //fontSize: 12,
                            color: context.colorScheme.onBackground
                                .withOpacity(0.8),
                          ),
                        ),
                      );
                    },
                  ),
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
          ],
        ),
      ),
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

  return list;
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

  factory AnimeVideo.fromJson(Map<String, dynamic> json) => AnimeVideo(
        id: json["id"],
        url: json["url"],
        imageUrl: json["image_url"],
        playerUrl: json["player_url"],
        name: json["name"],
        kind: AnimeVideoKind.fromValue(json["kind"]),
        hosting: json["hosting"],
      );
}

enum AnimeVideoKind {
  pv('pv'),
  characterTrailer('character_trailer'),
  cm('cm'),
  op('op'),
  ed('ed'),
  opEdClip('op_ed_clip'),
  clip('clip'),
  other('other'),
  episodePreview('episode_preview');

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
