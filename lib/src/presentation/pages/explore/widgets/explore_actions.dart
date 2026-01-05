import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/extensions/buildcontext.dart';

class ExploreActions extends StatelessWidget {
  const ExploreActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ExploreActionButton(
                label: 'Топ аниме',
                icon: Icons.movie_rounded,
                onTap: () => context.pushNamed('top_anime'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ExploreActionButton(
                primary: false,
                label: 'Топ манги',
                icon: Icons.menu_book_rounded,
                onTap: () => context.pushNamed('top_manga'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ExploreActionButton extends StatelessWidget {
  const ExploreActionButton({
    super.key,
    this.primary = true,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final bool primary;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = primary
        ? context.colorScheme.primaryContainer
        : context.colorScheme.tertiaryContainer;

    final contentColor = primary
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onTertiaryContainer;

    const borderRadius = 52.0;

    return Container(
      height: 64.0,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 6.0,
                ),
                Icon(
                  icon,
                  size: 24.0,
                  color: contentColor,
                ),
                const SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: contentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
