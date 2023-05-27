import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shikidev/src/constants/config.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../../domain/models/studio.dart';
import '../../../../domain/models/genre.dart';
import '../../../widgets/cached_image.dart';

class AnimeChipsWidget extends StatelessWidget {
  final List<Genre>? genres;
  final List<Studio>? studios;
  final String? score;
  final String rating;

  const AnimeChipsWidget({
    Key? key,
    required this.genres,
    required this.studios,
    required this.score,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          alignment: WrapAlignment.start,
          direction: Axis.horizontal,
          spacing: 8,
          runSpacing: 0, //0
          children: [
            if (score != null && score != '0.0')
              Chip(
                avatar: const Icon(Icons.star),
                padding: const EdgeInsets.all(0),
                shadowColor: Colors.transparent,
                elevation: 0,
                side: const BorderSide(width: 0, color: Colors.transparent),
                labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSecondaryContainer),
                backgroundColor: context.theme.colorScheme.secondaryContainer,
                label: Text(score!),
              ),
            if (rating != '?')
              Chip(
                padding: const EdgeInsets.all(0),
                shadowColor: Colors.transparent,
                elevation: 0,
                side: const BorderSide(width: 0, color: Colors.transparent),
                labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onSecondaryContainer),
                backgroundColor: context.theme.colorScheme.secondaryContainer,
                label: Text(rating),
              ),
            if (genres != null) ...[
              ...List.generate(
                genres!.length,
                (index) => ActionChip(
                  onPressed: () {},
                  padding: const EdgeInsets.all(0),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  side: const BorderSide(width: 0, color: Colors.transparent),
                  labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSecondaryContainer),
                  backgroundColor: context.theme.colorScheme.secondaryContainer,
                  label: Text(genres![index].russian ?? ""),
                ),
              ),
            ],
            if (studios != null) ...[
              ...List.generate(
                studios!.length,
                (index) => ActionChip(
                  onPressed: () {},
                  padding: const EdgeInsets.all(0),
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  side: const BorderSide(width: 0, color: Colors.transparent),
                  labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onSecondaryContainer),
                  backgroundColor: context.theme.colorScheme.secondaryContainer,
                  avatar: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                    child: CircleAvatar(
                      backgroundColor:
                          context.theme.colorScheme.secondaryContainer,
                      //backgroundColor: Colors.grey,
                      backgroundImage: CachedNetworkImageProvider(
                        '${AppConfig.staticUrl}${studios![index].image ?? '/assets/globals/missing/mini.png'}',
                        cacheManager: cacheManager,
                      ),
                    ),
                  ),
                  label: Text(studios![index].name ?? ""),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
