import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/enums/shiki_gql.dart';
import '../graphql_anime.dart';

class TitleGenres extends StatelessWidget {
  const TitleGenres(this.genres, {super.key});

  final List<GraphqlGenre> genres;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Wrap(
        spacing: 8.0,
        children: [
          const SizedBox(
            width: 8.0,
          ),
          ...List.generate(
            genres.length,
            (index) => _GenreChip(
              genre: genres[index],
              onTap: () {},
            ),
          ),
          const SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }
}

typedef GenreKindColor = List<Color>;

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.genre,
    required this.onTap,
  });

  final GraphqlGenre genre;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = kindToColor(context, genre.kind);

    return Tooltip(
      message: genre.kind.rusName,
      waitDuration: const Duration(milliseconds: 250),
      child: Card(
        elevation: 0,
        color: colors[0],
        margin: const EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            child: Text(
              genre.russian,
              style: context.textTheme.bodySmall?.copyWith(
                fontSize: 14,
                color: colors[1],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static GenreKindColor kindToColor(BuildContext ctx, GenreKind kind) {
    final cs = ctx.colorScheme;
    return switch (kind) {
      //GenreKind.demographic => [cs.primaryContainer, cs.onPrimaryContainer],
      //GenreKind.genre => [cs.secondaryContainer, cs.onSecondaryContainer],
      GenreKind.theme => [cs.tertiaryContainer, cs.onTertiaryContainer],
      _ => [cs.secondaryContainer, cs.onSecondaryContainer],
    };
  }
}
