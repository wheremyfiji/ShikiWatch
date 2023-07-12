import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/desc_with_text_element.dart';
import '../../../widgets/custom_element_bar.dart';

const List<String> mangaNames = [
  'В планах',
  'Читаю / Перечитываю',
  'Прочитано',
  'Отложено',
  'Брошено'
];

class UserMangaStatsWidget extends StatelessWidget {
  final List<int> list;

  const UserMangaStatsWidget({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    int sum = list.reduce((a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Манга и ранобе',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text('Всего: $sum', style: Theme.of(context).textTheme.bodySmall),
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
                  text: '${mangaNames[index]}: ${list[index]}',
                  color: getStatElementColorUserProfile(
                    dark: context.isDarkThemed,
                    index: index,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
