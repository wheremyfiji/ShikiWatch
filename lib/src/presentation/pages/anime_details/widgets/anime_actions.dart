import 'package:flutter/material.dart';

import '../../../../domain/models/anime.dart';
import '../../comments/comments_page.dart';
import '../external_links.dart';
import '../similar_animes.dart';

class AnimeActionsWidget extends StatelessWidget {
  final Anime anime;

  const AnimeActionsWidget({super.key, required this.anime});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
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
                child: Column(
                  children: const [
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
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          CommentsPage(
                        anime: anime,
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Column(
                  children: const [
                    Icon(Icons.topic), //chat
                    SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Обсуждение',
                      // style: TextStyle(
                      //   color: context.textTheme.bodyMedium?.color,
                      // ),
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
                child: Column(
                  children: const [
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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: const Text('A dialog is a type of modal window that\n'
              'appears in front of app content to\n'
              'provide critical information, or prompt\n'
              'for a decision to be made.'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
