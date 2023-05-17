import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/utils.dart';
import '../../../widgets/custom_card_button.dart';

class ExploreActions extends StatelessWidget {
  const ExploreActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomCardButton(
                label: 'Топ аниме',
                onTap: () {
                  context.pushNamed('top_anime');
                },
                icon: Icons.movie_rounded,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: CustomCardButton(
                label: 'Топ манги',
                onTap: () {
                  context.pushNamed('top_manga');
                },
                icon: Icons.menu_book_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            Expanded(
              child: CustomCardButton(
                label: 'Случайное',
                onTap: () {
                  showSnackBar(ctx: context, msg: 'Пока нельзя');
                },
                icon: Icons.shuffle_rounded,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: CustomCardButton(
                label: 'Календарь',
                onTap: () {
                  context.pushNamed('calendar');
                },
                icon: Icons.calendar_month_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
