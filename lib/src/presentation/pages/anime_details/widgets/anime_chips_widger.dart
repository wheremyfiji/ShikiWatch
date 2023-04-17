import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:shikidev/src/constants/config.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../../domain/models/anime.dart';

class AnimeChipsWidget extends StatelessWidget {
  final List<Genres>? genres;
  final List<Studios>? studios;
  final String? score;

  const AnimeChipsWidget({
    Key? key,
    required this.genres,
    required this.studios,
    required this.score,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      spacing: 8,
      runSpacing: 0, //0
      children: [
        Chip(
          avatar: const Icon(Icons.star),
          padding: const EdgeInsets.all(0),
          shadowColor: Colors.transparent,
          elevation: 0,
          side: const BorderSide(width: 0, color: Colors.transparent),
          labelStyle: context.theme.textTheme.bodyMedium
              ?.copyWith(color: context.theme.colorScheme.onSecondaryContainer),
          backgroundColor: context.theme.colorScheme.secondaryContainer,
          label: Text(score ?? '0'),
        ),
        if (genres != null) ...[
          ...List.generate(
            genres!.length,
            (index) => Chip(
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
            (index) => Chip(
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
                  backgroundColor: context.theme.colorScheme.secondaryContainer,
                  //backgroundColor: Colors.grey,
                  backgroundImage: ExtendedNetworkImageProvider(
                      '${AppConfig.staticUrl}${studios![index].image ?? '/assets/globals/missing/mini.png'}',
                      cache: true),
                ),
              ),
              label: Text(studios![index].name ?? ""),
            ),
          ),
        ],
      ],
    );
  }
}
