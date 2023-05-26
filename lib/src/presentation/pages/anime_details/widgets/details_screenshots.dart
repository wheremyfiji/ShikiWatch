import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../../constants/config.dart';
import '../../../../domain/models/anime.dart' as a;
import '../../../widgets/cached_image.dart';
import '../../../widgets/image_with_shimmer.dart';
import '../../../widgets/show_pop_up.dart';
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
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            InkWell(
              onTap: () {
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
              child: Text(
                'Больше',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
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
                  itemCount: data.screenshots!.length,
                  itemBuilder: (context, index) {
                    //final screenShot = data.screenshots![index];
                    final url = data.screenshots![index].original ??
                        data.screenshots![index].preview ??
                        '';
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GestureDetector(
                          onTap: () => showSlideUp(
                            context,
                            ImageViewer(
                              AppConfig.staticUrl + url,
                              cached: true,
                            ),
                          ),
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
            );
          },
        ),
      ],
    );
  }
}
