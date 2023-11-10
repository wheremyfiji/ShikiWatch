import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/riverpod_extensions.dart';
import '../../../services/http/http_service_provider.dart';
import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../../constants/config.dart';

class AnimeScreenshots {
  String? original;
  String? preview;

  AnimeScreenshots({this.original, this.preview});

  AnimeScreenshots.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    preview = json['preview'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original'] = original;
    data['preview'] = preview;
    return data;
  }
}

final animeScreenshotsProvider = FutureProvider.autoDispose
    .family<List<AnimeScreenshots>, int>((ref, id) async {
  final dio = ref.read(httpServiceProvider);
  final cancelToken = ref.cancelToken();

  final response = await dio.get(
    'animes/$id/screenshots',
    cancelToken: cancelToken,
  );

  final list = <AnimeScreenshots>[
    for (final e in response) AnimeScreenshots.fromJson(e),
  ];

  list.removeWhere((e) => (e.original == null || e.original!.isEmpty));

  return list;
}, name: 'animeScreenshotsProvider');

class AnimeScreenshotsPage extends ConsumerWidget {
  final int id;
  final String name;

  const AnimeScreenshotsPage({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenshots = ref.watch(animeScreenshotsProvider(id));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar.large(
              automaticallyImplyLeading: false,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Кадры'),
            ),
            ...screenshots.when(
              data: (data) {
                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final scr = data[index];

                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: GestureDetector(
                              onTap: () {
                                final multiImageProvider = _buildList(
                                  data: data,
                                  index: index,
                                );

                                showImageViewerPager(
                                  context,
                                  multiImageProvider,
                                  doubleTapZoomable: true,
                                  swipeDismissible: true,
                                  backgroundColor: Colors.black,
                                  closeButtonColor: Colors.white,
                                );
                              },
                              child: Container(
                                color: Colors.black,
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: CachedImage(
                                    AppConfig.staticUrl + scr.original!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        childCount: data.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 16 / 9,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                  ),
                ];
              },
              loading: () => [
                SliverToBoxAdapter(
                    child: Center(
                        child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 130),
                      child: const CircularProgressIndicator()),
                )))
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    err.toString(),
                    () => ref.refresh(animeScreenshotsProvider(id)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  MultiImageProvider _buildList({
    required List<AnimeScreenshots> data,
    required int index,
  }) {
    List<ImageProvider<Object>> imageProviders = [];

    for (var e in data) {
      imageProviders.add(
        CachedNetworkImageProvider(
          AppConfig.staticUrl + e.original!,
          cacheManager: cacheManager,
        ),
      );
    }

    MultiImageProvider multiImageProvider = MultiImageProvider(
      imageProviders,
      initialIndex: index,
    );

    return multiImageProvider;
  }
}
