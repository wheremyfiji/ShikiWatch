import 'package:flutter/material.dart';

import '../../../utils/extensions/buildcontext.dart';

import 'kodik/kodik_source_page.dart';
import 'anilibria_source_page.dart';

class SelectSourceSheet extends StatelessWidget {
  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String searchName;
  final String imageUrl;
  final List<String> searchList;

  const SelectSourceSheet({
    super.key,
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.searchName,
    required this.imageUrl,
    required this.searchList,
  });

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
                    KodikSourcePage(
                  shikimoriId: shikimoriId,
                  animeName: animeName,
                  searchName: searchName,
                  epWatched: epWatched,
                  imageUrl: imageUrl,
                  searchList: searchList,
                ),
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
                    AnilibriaSourcePage(
                  shikimoriId: shikimoriId,
                  animeName: animeName,
                  searchName: searchName,
                  epWatched: epWatched,
                  imageUrl: imageUrl,
                  searchList: searchList,
                ),
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
    required int shikimoriId,
    required int epWatched,
    required String animeName,
    required String search,
    required String imageUrl,
    required List<String> searchList,
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
        child: SelectSourceSheet(
          shikimoriId: shikimoriId,
          epWatched: epWatched,
          animeName: animeName,
          searchName: search,
          imageUrl: imageUrl,
          searchList: searchList,
        ),
      ),
    );
  }
}
