import 'package:flutter/material.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/anime.dart';
import '../../../widgets/cached_image.dart';

import '../screenshots_page.dart';

class TitleScreenshots extends StatelessWidget {
  final Anime data;
  const TitleScreenshots(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Кадры',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AnimeScreenshotsPage(
                      id: data.id ?? 0,
                      name: data.russian ?? data.name ?? '',
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                ),
              ),
              // TextButton(
              //   style: const ButtonStyle(visualDensity: VisualDensity.compact),
              //   onPressed: () => Navigator.push(
              //     context,
              //     PageRouteBuilder(
              //       pageBuilder: (context, animation1, animation2) =>
              //           AnimeScreenshotsPage(
              //         id: data.id ?? 0,
              //         name: data.russian ?? data.name ?? '',
              //       ),
              //       transitionDuration: Duration.zero,
              //       reverseTransitionDuration: Duration.zero,
              //     ),
              //   ),
              //   child: const Text(
              //     'Больше',
              //   ),
              // ),
            ],
          ),
        ),
        // const SizedBox(
        //   height: 8,
        // ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            scrollDirection: Axis.horizontal,
            itemCount: data.screenshots!.length,
            itemBuilder: (context, index) {
              final url = data.screenshots![index].original ??
                  data.screenshots![index].preview ??
                  '';

              final isFirstItem = index == 0;

              return GestureDetector(
                // onTap: () => showSlideUp(
                //   context,
                //   ImageViewer(
                //     AppConfig.staticUrl + url,
                //     cached: true,
                //   ),
                // ),

                onTap: () {
                  // MultiImageProvider multiImageProvider = MultiImageProvider(
                  //   [
                  //     CachedNetworkImageProvider(
                  //       AppConfig.staticUrl + data.screenshots![0].original!,
                  //       cacheManager: cacheManager,
                  //     ),
                  //     CachedNetworkImageProvider(
                  //       AppConfig.staticUrl + data.screenshots![1].original!,
                  //       cacheManager: cacheManager,
                  //     ),
                  //   ],
                  //   initialIndex: index,
                  // );

                  // showImageViewerPager(
                  //   context,
                  //   multiImageProvider,
                  //   doubleTapZoomable: true,
                  //   swipeDismissible: true,
                  //   backgroundColor: Colors.black,
                  //   closeButtonColor: Colors.white,
                  // );
                },

                child: Container(
                  margin: EdgeInsets.fromLTRB(isFirstItem ? 16 : 0, 0, 16, 0),
                  height: 180,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: (16 / 9),
                      child: Container(
                        color: Colors.black,
                        child: CachedImage(
                          AppConfig.staticUrl + url,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
