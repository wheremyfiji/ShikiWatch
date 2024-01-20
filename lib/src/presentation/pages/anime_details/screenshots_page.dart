import 'package:flutter/material.dart';

import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../utils/extensions/buildcontext.dart';
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

class AnimeScreenshotsPage extends HookConsumerWidget {
  final int id;
  final String name;
  final int selectedIndex;

  const AnimeScreenshotsPage({
    super.key,
    required this.id,
    required this.name,
    required this.selectedIndex,
  });

  String _screenshotUrl(int index, List<AnimeScreenshots> screenshots) =>
      '${AppConfig.staticUrl}${screenshots[index].original}';

  _pushViewer(
    BuildContext ctx, {
    required int index,
    required List<AnimeScreenshots> sources,
  }) =>
      Navigator.of(ctx, rootNavigator: true).push(
        _HeroDialogRoute(
          builder: (ctx) => InteractiveviewerGallery(
            sources: sources,
            initIndex: index,
            maxScale: 3.0,
            itemBuilder: (context, imageIndex, isFocus) {
              return Center(
                child: Hero(
                  tag: _screenshotUrl(
                    imageIndex,
                    sources,
                  ),
                  child: CachedImage(
                    _screenshotUrl(
                      imageIndex,
                      sources,
                    ),
                    fadeOutDuration: const Duration(milliseconds: 200),
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                  ),
                ),
              );
            },
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenshots = ref.watch(animeScreenshotsProvider(id));

    useEffect(() {
      if (selectedIndex == -1) {
        return;
      }

      if (screenshots.isLoading || screenshots.hasError) {
        return;
      }

      if (!screenshots.hasValue || screenshots.asData!.value.isEmpty) {
        return;
      }

      final data = screenshots.asData!.value;

      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _pushViewer(context, sources: data, index: selectedIndex),
      );

      return null;
    }, [screenshots]);

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
                    'Кадры',
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
            ...screenshots.when(
              data: (data) {
                return [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final url = _screenshotUrl(index, data);

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Hero(
                                  tag: url,
                                  child: Container(
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: CachedImage(
                                        url,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                type: MaterialType.transparency,
                                borderRadius: BorderRadius.circular(12),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () => _pushViewer(context,
                                      sources: data, index: index),
                                ),
                              ),
                            ],
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
                      //bottom: MediaQuery.of(context).padding.bottom,
                      bottom: MediaQuery.paddingOf(context).bottom,
                    ),
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
}

class _HeroDialogRoute<T> extends PageRoute<T> {
  _HeroDialogRoute({required this.builder}) : super();

  final WidgetBuilder builder;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  String? get barrierLabel => '';
}
