import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../domain/models/genre.dart';
import '../../../../domain/models/studio.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/shadowed_overflow_decorator.dart';

class TitleGenresStudios extends StatelessWidget {
  final List<Genre>? genres;
  final List<Studio>? studios;

  const TitleGenresStudios({
    super.key,
    required this.genres,
    required this.studios,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: ShadowedOverflowDecorator(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.0,
            children: [
              const SizedBox(
                width: 8.0,
              ),
              if (genres != null && genres!.isNotEmpty) ...[
                ...List.generate(
                  genres!.length,
                  (index) => ActionChip(
                    onPressed: () => context.pushNamed(
                      'explore_search',
                      queryParameters: {'genreId': '${genres![index].id}'},
                    ),
                    padding: const EdgeInsets.all(0),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(
                      width: 0,
                      color: Colors.transparent,
                    ),
                    labelStyle: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                    backgroundColor: context.colorScheme.secondaryContainer,
                    label: Text(genres![index].russian ?? ''),
                  ),
                ),
              ],
              if (studios != null && studios!.isNotEmpty) ...[
                ...List.generate(
                  studios!.length,
                  (index) => ActionChip(
                    onPressed: () => context.pushNamed(
                      'explore_search',
                      queryParameters: {'studioId': '${studios![index].id}'},
                    ),
                    padding: const EdgeInsets.all(0),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    side: const BorderSide(
                      width: 0,
                      color: Colors.transparent,
                    ),
                    labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
                      color: context.theme.colorScheme.onTertiaryContainer,
                    ),
                    backgroundColor:
                        context.theme.colorScheme.tertiaryContainer,
                    label: Text(studios![index].name ?? ''),
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
