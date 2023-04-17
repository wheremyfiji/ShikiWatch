import 'package:flutter/material.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/anime.dart' as a;
import '../../../widgets/image_with_shimmer.dart';
import '../moments_page.dart';

class AnimeScreenshots extends StatelessWidget {
  final a.Anime data;
  const AnimeScreenshots(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Кадры',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    //fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AnimeMomentsPage(
                      id: data.id ?? 0,
                      name: data.russian ?? data.name ?? '',
                    ),
                  ),
                );
              },
              child: const Text('Ещё'), // Показать все
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 120.0, //200 180
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: data.screenshots!.length,
            itemBuilder: (BuildContext context, int index) {
              final model = data.screenshots![index];

              return Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => HeroPhotoViewRouteWrapper(
                      //       imageProvider: CachedNetworkImageProvider(
                      //         kStaticUrl.toString() + (model.original ?? ''),
                      //       ),
                      //       heroTag:
                      //           kStaticUrl.toString() + (model.original ?? ''),
                      //     ),
                      //   ),
                      // );
                    },
                    child: AspectRatio(
                      aspectRatio: (16 / 9),
                      child: Container(
                        color: Colors.black,
                        child: ImageWithShimmerWidget(
                          fit: BoxFit.contain,
                          imageUrl: AppConfig.staticUrl +
                              (model.original ?? model.preview ?? ''),
                        ),
                      ),
                      //     Container(
                      //   color: Colors.black,
                      //   child: ExtendedImage.network(
                      //     AppConfig.staticUrl +
                      //         (model.original ?? model.preview ?? ''),
                      //     fit: BoxFit.contain,
                      //   ),
                      // ),
                    ),
                  ),
                ),
              );
            },
          ),
          //),
        ),
      ],
    );
  }
}
