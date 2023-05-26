import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/constants/config.dart';
import 'package:shikidev/src/services/http/http_service_provider.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../widgets/cached_image.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/show_pop_up.dart';

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

final animeMomentsProvider = FutureProvider.autoDispose
    .family<List<AnimeScreenshots>, int>((ref, id) async {
  final dio = ref.read(httpServiceProvider);
  final response = await dio.get('animes/$id/screenshots', needToCache: true);
  return [for (final e in response) AnimeScreenshots.fromJson(e)];
}, name: 'animeMomentsProvider');

class AnimeMomentsPage extends ConsumerWidget {
  final int id;
  final String name;
  const AnimeMomentsPage({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moments = ref.watch(animeMomentsProvider(id));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Кадры'),
          ),
          ...moments.when(
            data: (data) => [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  childCount: data.length,
                  (context, index) {
                    final moment = data[index];

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () => showSlideUp(
                            context,
                            ImageViewer(
                              AppConfig.staticUrl + (moment.original ?? ''),
                              cached: false,
                            ),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Image.network(
                              AppConfig.staticUrl + moment.original!,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return const _Placeholder();

                                // return Center(
                                //   child: CircularProgressIndicator(
                                //     value: loadingProgress.expectedTotalBytes !=
                                //             null
                                //         ? loadingProgress
                                //                 .cumulativeBytesLoaded /
                                //             loadingProgress.expectedTotalBytes!
                                //         : null,
                                //   ),
                                // );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
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
                  () => ref.refresh(animeMomentsProvider(id)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final bool isFailed;
  const _Placeholder({
    // ignore: unused_element
    this.isFailed = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isFailed) {
      return const Material(child: Icon(Icons.broken_image_outlined));
    }

    final baseColor = context.isLightThemed
        ? context.colorScheme.background.desaturate(50).darken(2)
        : context.colorScheme.surface;
    final highlightColor = context.isLightThemed
        ? context.colorScheme.background.desaturate(50).lighten(2)
        : context.colorScheme.surface.lighten(5);

    return Shimmer(
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: <Color>[
          baseColor,
          baseColor,
          highlightColor,
          baseColor,
          baseColor
        ],
        stops: const <double>[0.0, 0.35, 0.5, 0.65, 1.0],
      ),
      period: const Duration(milliseconds: 700),
      child: Container(
        color: Colors.black,
        child: const SizedBox.expand(),
      ),
    );
  }
}
