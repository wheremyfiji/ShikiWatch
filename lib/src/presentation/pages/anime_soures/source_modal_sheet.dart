import 'package:flutter/material.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../utils/extensions/buildcontext.dart';

import 'kodik/kodik_source_page.dart';
import 'anilibria_source_page.dart';

class SelectSourceSheet extends StatelessWidget {
  const SelectSourceSheet(
    this.extra, {
    super.key,
  });

  final AnimeSourcePageExtra extra;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Text(
            'Выбор источника для поиска серий',
            style: context.textTheme.titleLarge,
          ),
        ),
        Card(
          color: context.colorScheme.secondaryContainer,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.info_rounded,
                    color: context.colorScheme.onSecondaryContainer,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Задать приоритетный вариант можно в настройках приложения',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    KodikSourcePage(extra),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          title: const Text('Kodik'),
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    AnilibriaSourcePage(extra),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          title: const Text('AniLib'),
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    AnilibriaSourcePage(extra),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          title: const Text('AniLibria'),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required AnimeSourcePageExtra extra,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: context.colorScheme.background,
      elevation: 0,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (_) => SafeArea(
        child: SelectSourceSheet(extra),
      ),
    );
  }
}
