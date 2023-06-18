import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8,
        runSpacing: 0,
        children: [
          const SizedBox(
            width: 8.0,
          ),
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
                onPressed: () => context.pushNamed('explore_search',
                    queryParameters: {'genreId': '${genres![index].id}'}),
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
                onPressed: () => context.pushNamed('explore_search',
                    queryParameters: {'studioId': '${studios![index].id}'}),
                padding: const EdgeInsets.all(0),
                shadowColor: Colors.transparent,
                elevation: 0,
                side: const BorderSide(width: 0, color: Colors.transparent),
                labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
                    color: context.theme.colorScheme.onTertiaryContainer),
                backgroundColor: context.theme.colorScheme.tertiaryContainer,
                avatar: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                  child: CircleAvatar(
                    backgroundColor:
                        context.theme.colorScheme.secondaryContainer,
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
          const SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }
}
