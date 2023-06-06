import 'package:flutter/material.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../../domain/models/genre.dart';
import '../../../../domain/models/publisher.dart';
import '../../../widgets/cool_chip.dart';

class MangaChipsWidget extends StatelessWidget {
  final List<Genre>? genres;
  final List<Publisher>? publishers;
  final String? score;

  const MangaChipsWidget({
    super.key,
    required this.genres,
    required this.publishers,
    required this.score,
  });

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
          if (genres != null) ...[
            ...List.generate(genres!.length,
                (index) => CoolChip(label: genres![index].russian ?? "")),
          ],
          if (publishers != null) ...[
            ...List.generate(publishers!.length,
                (index) => CoolChip(label: publishers![index].name ?? "")),
          ],
          const SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }
}
