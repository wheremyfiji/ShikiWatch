import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/desc_with_text_element.dart';
import '../../../widgets/custom_element_bar.dart';

const List<String> _names = [
  'Запланировано',
  'Просмотрено',
  'Смотрю',
  'Брошено',
  'Отложено'
];

class TitleRatesWidget extends StatelessWidget {
  final List<int> statsValues;

  const TitleRatesWidget(this.statsValues, {super.key});

  @override
  Widget build(BuildContext context) {
    int sum = statsValues.reduce((a, b) => a + b);
    final isDarkThemed = context.isDarkThemed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'В списках', //Статистика
              style: context.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Всего: $sum',
              style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onBackground.withOpacity(0.8)),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        CustomElementBar(
          values: statsValues,
          height: 32,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
          spacing: 0.0,
          runSpacing: 8.0,
          direction: Axis.horizontal,
          children: [
            ...List.generate(
              statsValues.length,
              (index) {
                return DescWithTextElement(
                  text: '${_names[index]}: ${statsValues[index]}',
                  color: getStatElementColor(
                    dark: isDarkThemed,
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
