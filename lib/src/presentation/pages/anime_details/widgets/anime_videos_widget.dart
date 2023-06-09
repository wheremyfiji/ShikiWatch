import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Видео',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              // InkWell(
              //   onTap: () {},
              //   child: Text(
              //     'Больше',
              //     style: context.textTheme.bodyLarge?.copyWith(
              //       fontWeight: FontWeight.bold,
              //       color: context.theme.colorScheme.primary,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(0),
            itemCount: data.videos!.length,
            itemBuilder: (context, index) {
              final isFirstItem = index == 0;
              final model = data.videos![index];

              String desc = model.name ?? '';

              if (desc.isEmpty) {
                desc = model.kind ?? '';
              }

              return GestureDetector(
                onTap: () => launchUrlString(
                  model.url ?? '',
                  mode: LaunchMode.externalApplication,
                ),
                child: Container(
                  margin: EdgeInsets.fromLTRB(isFirstItem ? 16 : 0, 0, 16, 0),
                  height: 180,
                  child: ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: BorderRadius.circular(12),
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
      ],
    );
  }
}
