import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';
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
              title: genres[index].russian,
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

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.title,
    required this.onTap,
  });

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      //elevation: 4,
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
            title,
            style: context.textTheme.bodySmall?.copyWith(
              fontSize: 14,
              color: context.colorScheme.onSurfaceVariant,
            ),
            // style: TextStyle(
            //   color: context.colorScheme.onSurfaceVariant,
            // ),
          ),
        ),
      ),
    );
  }
}
