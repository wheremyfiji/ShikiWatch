import 'package:flutter/material.dart';

import '../../../widgets/custom_element_bar.dart';
import '../../../widgets/desc_with_text_element.dart';

const List<String> mangaNames = [
  'В планах',
  'Читаю / Перечитываю',
  'Прочитано',
  'Брошено',
  'Отложено'
];

class UserMangaStatsWidget extends StatelessWidget {
  final List<int> list;

  const UserMangaStatsWidget({super.key, required this.list});

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
              'Манга и ранобе',
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
          //crossAxisAlignment: WrapCrossAlignment.start,
          //alignment: WrapAlignment.spaceEvenly,
          //runAlignment: WrapAlignment.start,
          children: [
            ...List.generate(
              list.length,
              (index) {
                return DescWithTextElement(
                  text: '${mangaNames[index]}: ${list[index]}',
                  color: getStatElementColorUserProfile(
                    ctx: context,
                    index: index,
                  ),
                );
              },
            ),
            // DescWithTextElement(
            //   text: 'В планах: ${list[0]}',
            //   color: getStatElementColor(ctx: context, index: 0),
            // ),
            // DescWithTextElement(
            //   text: 'Читаю / Перечитываю: ${list[1]}',
            //   color: getStatElementColor(ctx: context, index: 1),
            // ),
            // DescWithTextElement(
            //   text: 'Просмотрено: ${list[2]}',
            //   color: getStatElementColor(ctx: context, index: 2),
            // ),
            // DescWithTextElement(
            //   text: 'Брошено: ${list[3]}',
            //   color: getStatElementColor(ctx: context, index: 3),
            // ),
            // DescWithTextElement(
            //   text: 'Отложено: ${list[4]}',
            //   color: getStatElementColor(ctx: context, index: 4),
            // ),
          ],
        ),
      ],
    );
  }
}
