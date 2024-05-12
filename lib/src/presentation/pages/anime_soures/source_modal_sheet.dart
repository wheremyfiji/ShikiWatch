import 'package:flutter/material.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../utils/extensions/buildcontext.dart';

import 'anilib/anilib_source_page.dart';
import 'kodik/kodik_source_page.dart';
import 'anilibria/anilibria_source_page.dart';

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
        const Card(
          margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: ListTile(
            leading: Icon(Icons.search_rounded),
            title: Text(
              'Выбор источника для поиска серий',
            ),
            subtitle: Text(
              'Установить вариант по умолчанию можно в настройках приложения',
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
          title: const Text('AniLibria'),
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) =>
                    AnilibSourcePage(extra),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
          title: const Text('AniLib'),
          subtitle: const Text('Прогресс просмотра не сохраняется'),
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
