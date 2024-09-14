import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../domain/models/pages_extra.dart';
import '../../../utils/extensions/buildcontext.dart';

import 'anilib/anilib_source_page.dart';
import 'anime365/anime365_provider.dart';
import 'anime365/anime365_source_page.dart';
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
        Consumer(
          builder: (context, ref, child) {
            final userAsync = ref.watch(anime365UserProvider);

            return userAsync.when(
              data: (user) {
                final isLogined = user.isLogined;
                final isPremium = user.isPremium;

                final subtitle = !isLogined
                    ? 'Перейди в настройки и войди в свой аккаунт для продолжения'
                    : !isPremium
                        ? 'Для просмотра необходима премиум подписка'
                        : 'Прогресс просмотра не сохраняется';

                // if (!isLogined) {
                //   return ListTile(
                //     onTap: () {
                //       Navigator.pop(context);
                //     },
                //     title: const Text('Anime365'),
                //     subtitle:
                //         const Text('Войди в свой аккаунт для продолжения'),
                //   );
                // }

                return ListTile(
                  onTap: isLogined && isPremium
                      ? () {
                          Navigator.pop(context);

                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation1, animation2) =>
                                  Anime365SourcePage(extra),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        }
                      : null,
                  title: const Text('Anime365'),
                  subtitle: Text(subtitle),
                );
              },
              error: (_, __) => const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
            );
          },
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
