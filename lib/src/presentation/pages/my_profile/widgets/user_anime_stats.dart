import 'package:flutter/material.dart';

import '../../../widgets/custom_element_bar.dart';
import '../../../widgets/desc_with_text_element.dart';

const List<String> animeNames = [
  'В планах',
  'Смотрю / Пересматриваю',
  'Просмотрено',
  'Брошено',
  'Отложено'
];

class UserAnimeStatsWidget extends StatelessWidget {
  final List<int> list;

  const UserAnimeStatsWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    //return const SizedBox.shrink();
    int sum = list.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Аниме',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    //fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Всего: $sum',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  //fontSize: 15,
                  //fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        if (sum != 0) ...[
          CustomElementBar(
            values: list,
            height: 36,
            p: true,
          ),
          const SizedBox(
            height: 8,
          ),
        ],
        Wrap(
          spacing: 4.0,
          runSpacing: 8.0,
          direction: Axis.horizontal,
          children: [
            ...List.generate(
              list.length,
              (index) {
                return DescWithTextElement(
                  text: '${animeNames[index]}: ${list[index]}',
                  color: getStatElementColorUserProfile(
                      ctx: context, index: index),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
