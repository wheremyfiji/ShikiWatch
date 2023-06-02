import 'package:flutter/material.dart';

import '../../../../domain/models/anime.dart';
import '../../comments/comments_page.dart';
import '../external_links.dart';
import '../similar_animes.dart';

class AnimeActionsWidget extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onBtnPress;

  const AnimeActionsWidget({super.key, required this.anime, this.onBtnPress});

  String getStatus(String value, int? c) {
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

  IconData getIcon(String value) {
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
    final int? topicId = anime.topicId;

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
                    child: const Column(
                      children: [
                        Icon(Icons.join_inner),
                        SizedBox(
                          height: 4,
                        ),
                        Text('Похожее'),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: (topicId == null || topicId == 0)
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation1, animation2) =>
                                        CommentsPage(
                                  topicId: topicId,
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
                        Text(
                          'Обсуждение',
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _openFullscreenDialog(context);
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.link),
                        SizedBox(
                          height: 4,
                        ),
                        Text('Ссылки'),
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
                    ? getStatus(anime.userRate!.status ?? '', 0)
                    : 'Добавить в список'),
                icon: Icon(getIcon(anime.userRate?.status ?? '')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullscreenDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      useSafeArea: false,
      builder: (context) => Dialog.fullscreen(
        child: ExternalLinksWidget(
          animeId: anime.id!,
        ),
      ),
    );
  }
}
