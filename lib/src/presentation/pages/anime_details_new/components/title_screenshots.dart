import 'package:flutter/material.dart';

import '../../../widgets/cached_image.dart';
import '../graphql_anime.dart';

class AnimeScreenshots extends StatelessWidget {
  const AnimeScreenshots(
    this.screenshots, {
    super.key,
    this.height = 160,
  });

  final List<GraphqlScreenshot> screenshots;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 10.0, bottom: 8.0),
          child: Text(
            'Кадры',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: height,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            scrollDirection: Axis.horizontal,
            itemCount: screenshots.length,
            itemBuilder: (context, index) {
              final item = screenshots[index];

              final isFirstItem = index == 0;

              return Container(
                height: height,
                margin: EdgeInsets.fromLTRB(isFirstItem ? 16 : 0, 0, 16, 0),
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: (16 / 9),
                      child: Container(
                        color: Colors.black,
                        child: CachedImage(
                          item.x332Url,
                          fit: BoxFit.contain,
                          memCacheHeight: 240,
                        ),
                      ),
                    ),
                    Align(
                      child: SizedBox(
                        height: height,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {},
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
