import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/constants/config.dart';
import 'package:shikidev/src/services/http/http_service_provider.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../widgets/error_widget.dart';

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
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            AppConfig.staticUrl + moment.original!,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                          // ExtendedImage.network(
                          //   AppConfig.staticUrl + moment.original!,
                          //   //compressionRatio: 0.2,
                          //   maxBytes: null,
                          //   cacheWidth: null,
                          //   cacheHeight: null,
                          //   fit: BoxFit.contain,
                          //   //mode: ExtendedImageMode.gesture,
                          //   // initGestureConfigHandler: (state) {
                          //   //   return GestureConfig(
                          //   //     minScale: 1.0,
                          //   //     animationMinScale: 0.7,
                          //   //     maxScale: 3.0,
                          //   //     animationMaxScale: 3.5,
                          //   //     speed: 1.0,
                          //   //     inertialSpeed: 100.0,
                          //   //     initialScale: 1.0,
                          //   //     inPageView: false,
                          //   //     initialAlignment: InitialAlignment.center,
                          //   //   );
                          //   // },
                          //   cache: false,
                          //   //enableLoadState: false,
                          //   loadStateChanged: (ExtendedImageState state) {
                          //     switch (state.extendedImageLoadState) {
                          //       case LoadState.loading:
                          //         return const _Placeholder();
                          //       // return const Center(
                          //       //   child: CircularProgressIndicator(),
                          //       // );
                          //       case LoadState.completed:
                          //         return state.completedWidget;
                          //       case LoadState.failed:
                          //         return const Icon(Icons.error);
                          //     }
                          //     //return null;
                          //   },
                          //   // loadStateChanged: (state) {
                          //   //   if (state.wasSynchronouslyLoaded &&
                          //   //       state.isCompleted) {
                          //   //     return state.completedWidget;
                          //   //   }

                          //   //   return AnimatedSwitcher(
                          //   //     duration: const Duration(milliseconds: 150),
                          //   //     child: state.isCompleted
                          //   //         ? state.completedWidget
                          //   //         : _Placeholder(isFailed: state.isFailed),
                          //   //     layoutBuilder:
                          //   //         (currentChild, previousChildren) {
                          //   //       return Stack(
                          //   //         alignment: Alignment.center,
                          //   //         fit: StackFit.passthrough,
                          //   //         children: [
                          //   //           ...previousChildren,
                          //   //           if (currentChild != null) currentChild,
                          //   //         ],
                          //   //       );
                          //   //     },
                          //   //   );
                          //   // },
                          // ),
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

// class TetsPage extends StatefulWidget {
//   final List<AnimeScreenshots> pics;
//   final int index;
//   const TetsPage({super.key, required this.index, required this.pics});

//   @override
//   State<TetsPage> createState() => _TetsPageState();
// }

// class _TetsPageState extends State<TetsPage> {
//   @override
//   Widget build(BuildContext context) {
//     final int currentIndex;
//     return ExtendedImageGesturePageView.builder(
//       itemBuilder: (BuildContext context, int index) {
//         var item = widget.pics[index].original;
//         Widget image = ExtendedImage.network(
//           item ?? '',
//           fit: BoxFit.contain,
//           mode: ExtendedImageMode.gesture,
//           gestureConfig: GestureConfig(
//               inPageView: true,
//               initialScale: 1.0,
//               //you can cache gesture state even though page view page change.
//               //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
//               cacheGesture: false),
//         );
//         image = Container(
//           padding: const EdgeInsets.all(5.0),
//           child: image,
//         );
//         if (index == currentIndex) {
//           return Hero(
//             tag: item + index.toString(),
//             child: image,
//           );
//         } else {
//           return image;
//         }
//       },
//       itemCount: widget.pics.length,
//       onPageChanged: (int index) {
//         currentIndex = index;
//         rebuild.add(index);
//       },
//       controller: ExtendedPageController(
//         initialPage: widget.index,
//       ),
//       scrollDirection: Axis.horizontal,
//     );
//   }
// }

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
