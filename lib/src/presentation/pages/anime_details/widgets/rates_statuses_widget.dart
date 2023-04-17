import 'package:flutter/material.dart';

import '../../../widgets/custom_element_bar.dart';
import '../../../widgets/desc_with_text_element.dart';

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
          //crossAxisAlignment: WrapCrossAlignment.start,
          //alignment: WrapAlignment.spaceEvenly,
          //runAlignment: WrapAlignment.start,
          children: [
            ...List.generate(
              statsValues.length,
              (index) {
                return DescWithTextElement(
                  text: '${names[index]}: ${statsValues[index]}',
                  color: getStatElementColor(ctx: context, index: index),
                );
              },
            ),
            // DescWithTextElement(
            //   text: 'Запланировано: ${statsValues[0]}',
            //   color: getStatElementColor(ctx: context, index: 0),
            // ),
            // DescWithTextElement(
            //   text: 'Просмотрено: ${statsValues[1]}',
            //   color: getStatElementColor(ctx: context, index: 1),
            // ),
            // DescWithTextElement(
            //   text: 'Смотрю: ${statsValues[2]}',
            //   color: getStatElementColor(ctx: context, index: 2),
            // ),
            // DescWithTextElement(
            //   text: 'Брошено: ${statsValues[3]}',
            //   color: getStatElementColor(ctx: context, index: 3),
            // ),
            // DescWithTextElement(
            //   text: 'Отложено: ${statsValues[4]}',
            //   color: getStatElementColor(ctx: context, index: 4),
            // ),
          ],
        ),
      ],
    );
  }
}

class AnimeRatesStatusesWidget2 extends StatelessWidget {
  final List<Map<String, dynamic>>? statuses;
  const AnimeRatesStatusesWidget2({super.key, required this.statuses});

  Color getColor(int index) {
    switch (index) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.purple;

      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Colors.white
            : Colors.black;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Статистика',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    //fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // TextButton(
            //   onPressed: () {},
            //   child: const Text('Показать все'),
            // ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 160.0, //200
            maxWidth: 600,
          ),
          child: const Text(''),
          // DChartBar(
          //   animate: false,
          //   //minimumPaddingBetweenLabel: 4,
          //   verticalDirection: false,
          //   domainLabelPaddingToAxisLine: 16,
          //   axisLineTick: 1,
          //   axisLinePointTick: 1,
          //   axisLinePointWidth: 8,
          //   measureLabelPaddingToAxisLine: 16,
          //   //barColor: (barData, index, id) => Colors.green,
          //   showBarValue: true,
          //   barValue: (barData, index) => '${barData['measure']}',
          //   barValuePosition: BarValuePosition.auto,
          //   barValueAnchor: BarValueAnchor.middle,

          //   //measureMin: 0,
          //   //measureMax: 11000,

          //   domainLabelColor: textColor,
          //   measureLabelColor: textColor,
          //   barValueColor: context.theme.colorScheme.onPrimaryContainer,
          //   //axisLineColor: context.theme.colorScheme.onBackground,
          //   //axisLineColor: context.theme.textTheme.bodyLarge!.color,
          //   axisLineColor: textColor,
          //   data: [
          //     {
          //       'id': 'Bar',
          //       'data': statuses ?? [],
          //       // 'data': [
          //       //   {'domain': 'Запланировано', 'measure': 9928},
          //       //   {'domain': 'Просмотрено', 'measure': 229},
          //       //   {'domain': 'Смотрю', 'measure': 3887},
          //       //   {'domain': 'Брошено', 'measure': 184},
          //       //   {'domain': 'Отложено', 'measure': 291}
          //       // ],
          //     },
          //   ],
          //   barColor: (barData, index, id) =>
          //       context.theme.colorScheme.primaryContainer,
          //   // barColor: (barData, index, id) {
          //   //   switch (index) {
          //   //     case 0:
          //   //       return MediaQuery.of(context).platformBrightness ==
          //   //               Brightness.dark
          //   //           ? Colors.lime.shade200
          //   //           : Colors.lime.shade600;
          //   //     case 1:
          //   //       return MediaQuery.of(context).platformBrightness ==
          //   //               Brightness.dark
          //   //           ? Colors.green.shade200
          //   //           : Colors.green.shade600;
          //   //     case 2:
          //   //       return MediaQuery.of(context).platformBrightness ==
          //   //               Brightness.dark
          //   //           ? Colors.deepPurple.shade200
          //   //           : Colors.deepPurple.shade600;
          //   //     case 3:
          //   //       return MediaQuery.of(context).platformBrightness ==
          //   //               Brightness.dark
          //   //           ? Colors.red.shade200
          //   //           : Colors.red.shade600;
          //   //     case 4:
          //   //       return MediaQuery.of(context).platformBrightness ==
          //   //               Brightness.dark
          //   //           ? Colors.blue.shade200
          //   //           : Colors.blue.shade600;
          //   //     default:
          //   //       return Colors.white;
          //   //   }
          //   // },
          // ),
          //
          //
          // DChartPie(
          //   animate: false,
          //   labelPosition: PieLabelPosition.outside,
          //   //labelColor: Colors.white,
          //   labelColor:
          //       MediaQuery.of(context).platformBrightness == Brightness.dark
          //           ? Colors.white
          //           : Colors.black,
          //   showLabelLine: false,
          //   strokeWidth: 0,
          //   // data: const [
          //   //   {'domain': 'Flutter', 'measure': 28},
          //   //   {'domain': 'React Native', 'measure': 27},
          //   //   {'domain': 'Ionic', 'measure': 20},
          //   //   {'domain': 'Cordova', 'measure': 15},
          //   // ],
          //   data: statuses ?? [],
          //   // data: const [
          //   //   {'name': 'Запланировано', 'value': 9928},  0
          //   //   {'name': 'Просмотрено', 'value': 229},     1
          //   //   {'name': 'Смотрю', 'value': 3887},         2
          //   //   {'name': 'Брошено', 'value': 184},         3
          //   //   {'name': 'Отложено', 'value': 291}         4
          //   // ],

          //   // pieLabel: (pieData, index) {
          //   //   return "${pieData['domain']}:\n${pieData['measure']}";
          //   // },
          //   //fillColor: (pieData, index) => Colors.purple,
          //   fillColor: (pieData, index) {
          //     switch (index) {
          //       case 0:
          //         return MediaQuery.of(context).platformBrightness ==
          //                 Brightness.dark
          //             ? Colors.lime.shade200
          //             : Colors.lime.shade600;
          //       case 1:
          //         return MediaQuery.of(context).platformBrightness ==
          //                 Brightness.dark
          //             ? Colors.green.shade200
          //             : Colors.green.shade600;
          //       //return Colors.green.shade200;
          //       case 2:
          //         return MediaQuery.of(context).platformBrightness ==
          //                 Brightness.dark
          //             ? Colors.blue.shade200
          //             : Colors.blue.shade600;
          //       //return Colors.blue.shade200;
          //       case 3:
          //         return MediaQuery.of(context).platformBrightness ==
          //                 Brightness.dark
          //             ? Colors.red.shade200
          //             : Colors.red.shade600;
          //       //return Colors.red.shade200;
          //       case 4:
          //         return MediaQuery.of(context).platformBrightness ==
          //                 Brightness.dark
          //             ? Colors.deepOrange.shade200
          //             : Colors.deepOrange.shade600;
          //       //return Colors.deepOrange.shade200;
          //       default:
          //         return Colors.white;
          //     }
          //   },
          // ),
        ),
        // Row(children: [

        // ],),
      ],
    );
  }
}
