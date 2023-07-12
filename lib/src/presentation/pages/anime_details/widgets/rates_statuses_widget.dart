import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/desc_with_text_element.dart';
import '../../../widgets/custom_element_bar.dart';

const List<String> names = [
  'Запланировано',
  'Просмотрено',
  'Смотрю',
  'Брошено',
  'Отложено'
];

class AnimeRatesStatusesWidget extends StatelessWidget {
  final List<int> statsValues;
  const AnimeRatesStatusesWidget({super.key, required this.statsValues});

  @override
  Widget build(BuildContext context) {
    int sum = statsValues.reduce((a, b) => a + b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Статистика',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              'Всего: $sum',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        CustomElementBar(
          values: statsValues,
          height: 36,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          spacing: 4.0,
          runSpacing: 8.0,
          direction: Axis.horizontal,
          children: [
            ...List.generate(
              statsValues.length,
              (index) {
                return DescWithTextElement(
                  text: '${names[index]}: ${statsValues[index]}',
                  color: getStatElementColor(
                      dark: context.isDarkThemed, index: index),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}
