import 'package:flutter/material.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/anime.dart' as a;
import '../../../widgets/image_with_shimmer.dart';

import '../screenshots_page.dart';

class AnimeScreenshots extends StatelessWidget {
  final a.Anime data;
  const AnimeScreenshots(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
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
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimeScreenshotsPage(
                      id: data.id ?? 0,
                      name: data.russian ?? data.name ?? '',
                    ),
                  ),
                ),
                child: const Text(
                  'Больше',
                ),
              ),
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
                        child: ImageWithShimmerWidget(
                          fit: BoxFit.contain,
                          imageUrl: AppConfig.staticUrl + url,
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
