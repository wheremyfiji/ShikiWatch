import 'package:flutter/material.dart';

import '../../../../domain/models/anime.dart';
import '../../comments/comments_page.dart';
import '../anime_franchise_page.dart';
import '../similar_animes.dart';

class AnimeActionsWidget extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onBtnPress;

  const AnimeActionsWidget({super.key, required this.anime, this.onBtnPress});

  static String _getStatus(String value, int? c) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Смотрю',
      'rewatching': 'Пересматриваю',
      'completed': 'Просмотрено',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? '';

    return (c != 0 && value == 'watching') ? '$status (Серия $c)' : status;
  }

  static IconData _getIcon(String value) {
    IconData icon;

    const map = {
      'planned': Icons.event_available,
      'watching': Icons.remove_red_eye,
      'rewatching': Icons.refresh,
      'completed': Icons.done_all,
      'on_hold': Icons.pause,
      'dropped': Icons.close
    };

    icon = map[value] ?? Icons.add_rounded;

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            SimilarAnimesPage(animeId: anime.id!),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
                    // style: TextButton.styleFrom(
                    //   foregroundColor: context.colorScheme.onBackground,
                    // ),
                    child: const Column(
                      children: [
                        Icon(Icons.join_inner),
                        SizedBox(
                          height: 4,
                        ),
                        Text('Похожее', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: (anime.topicId == null || anime.topicId == 0)
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        CommentsPage(
                                  topicId: anime.topicId!,
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                    child: const Column(
                      children: [
                        Icon(Icons.topic), //chat
                        SizedBox(
                          height: 4,
                        ),
                        Text('Обсуждение', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            AnimeFranchisePage(anime.id!),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.list_rounded),
                        SizedBox(
                          height: 4,
                        ),
                        Text('Хронология', overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onBtnPress,
                label: Text(anime.userRate != null
                    ? _getStatus(anime.userRate!.status ?? '', 0)
                    : 'Добавить в список'),
                icon: Icon(_getIcon(anime.userRate?.status ?? '')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _openFullscreenDialog(BuildContext context) {
  //   showDialog<void>(
  //     context: context,
  //     useRootNavigator: false,
  //     useSafeArea: false,
  //     builder: (context) => Dialog.fullscreen(
  //       child: ExternalLinksWidget(
  //         animeId: anime.id!,
  //       ),
  //     ),
  //   );
  // }
}
