import 'package:flutter/material.dart';

import '../../../../domain/models/genre.dart';
import '../../../../domain/models/publisher.dart';
import '../../../widgets/cool_chip.dart';
import '../../../widgets/shadowed_overflow_decorator.dart';

class MangaGenresWidget extends StatelessWidget {
  final List<Genre>? genres;
  final List<Publisher>? publishers;

  const MangaGenresWidget({
    super.key,
    required this.genres,
    required this.publishers,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ShadowedOverflowDecorator(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8,
            children: [
              const SizedBox(
                width: 8.0,
              ),
              if (genres != null && genres!.isNotEmpty) ...[
                ...List.generate(
                  genres!.length,
                  (index) => CoolChip(label: genres![index].russian ?? ""),
                ),
              ],
              if (publishers != null && publishers!.isNotEmpty) ...[
                ...List.generate(
                  publishers!.length,
                  (index) => CoolChip(
                    label: publishers![index].name ?? "",
                    useTertiaryColors: true,
                  ),
                ),
              ],
              const SizedBox(
                width: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
