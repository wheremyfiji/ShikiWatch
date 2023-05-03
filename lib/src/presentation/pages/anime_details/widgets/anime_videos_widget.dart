import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../widgets/image_with_shimmer.dart';
import '../../../../domain/models/anime.dart';

class AnimeVideosMobileWidget extends StatelessWidget {
  final Anime data;
  const AnimeVideosMobileWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Видео',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    //fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const TextButton(
              onPressed: null,
              child: Text('Ещё'),
            ),
          ],
        ),
        LayoutBuilder(
          builder: (ctx, constr) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: constr.maxWidth,
                height: 180,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: data.videos!.length,
                  itemBuilder: (BuildContext context, int index) {
                    final model = data.videos![index];

                    String desc = model.name ?? '';

                    if (desc.isEmpty) {
                      desc = model.kind ?? '';
                    }

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: ClipRRect(
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () {
                            launchUrlString(
                              model.url ?? '',
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          child: Stack(
                            children: [
                              AspectRatio(
                                aspectRatio: (16 / 9),
                                child: ImageWithShimmerWidget(
                                  imageUrl: model.imageUrl ?? '',
                                ),
                              ),
                              Positioned(
                                left: -1,
                                right: -1,
                                top: 40,
                                bottom: -1,
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  padding: const EdgeInsets.all(6.0),
                                  alignment: Alignment.bottomCenter,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Colors.black.withAlpha(0),
                                        Colors.black54,
                                        Colors.black87,
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    //'Тизер',
                                    //model.name ?? model.kind ?? '',
                                    desc,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        // ConstrainedBox(
        //   constraints: const BoxConstraints(
        //     maxHeight: 120.0, //200
        //   ),
        //   child: ListView.builder(
        //     shrinkWrap: true,
        //     scrollDirection: Axis.horizontal,
        //     itemCount: data.videos!.length,
        //     itemBuilder: (BuildContext context, int index) {
        //       final model = data.videos![index];

        //       String desc = model.name ?? '';

        //       if (desc.isEmpty) {
        //         desc = model.kind ?? '';
        //       }

        //       return Padding(
        //         padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
        //         child: ClipRRect(
        //           clipBehavior: Clip.hardEdge,
        //           borderRadius: BorderRadius.circular(12),
        //           child: GestureDetector(
        //             onTap: () {
        //               launchUrlString(
        //                 model.url ?? '',
        //                 mode: LaunchMode.externalApplication,
        //               );
        //             },
        //             child: Stack(
        //               children: [
        //                 AspectRatio(
        //                   aspectRatio: (16 / 9),
        //                   child: ImageWithShimmerWidget(
        //                     imageUrl: model.imageUrl ?? '',
        //                   ),
        //                 ),
        //                 Positioned(
        //                   left: -1,
        //                   right: -1,
        //                   top: 40,
        //                   bottom: -1,
        //                   child: Container(
        //                     clipBehavior: Clip.hardEdge,
        //                     padding: const EdgeInsets.all(6.0),
        //                     alignment: Alignment.bottomCenter,
        //                     decoration: BoxDecoration(
        //                       gradient: LinearGradient(
        //                         begin: Alignment.topCenter,
        //                         end: Alignment.bottomCenter,
        //                         colors: <Color>[
        //                           Colors.black.withAlpha(0),
        //                           Colors.black54,
        //                           Colors.black87,
        //                         ],
        //                       ),
        //                     ),
        //                     child: Text(
        //                       //'Тизер',
        //                       //model.name ?? model.kind ?? '',
        //                       desc,
        //                       style: const TextStyle(color: Colors.white),
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        //   //),
        // ),
      ],
    );
  }
}
