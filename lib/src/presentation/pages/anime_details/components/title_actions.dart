import 'package:flutter/material.dart';

import '../../../../domain/models/anime.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/shadowed_overflow_decorator.dart';
import '../../comments/comments_page.dart';
import '../anime_franchise_page.dart';
import '../external_links.dart';
import '../similar_animes.dart';
import '../widgets/user_anime_rate.dart';

class TitleActions extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onBtnPress;

  const TitleActions(
    this.anime, {
    super.key,
    this.onBtnPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16), //10
      child: ShadowedOverflowDecorator(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8,
            children: [
              const SizedBox(
                width: 8.0,
              ),
              _UserRateItem(
                anime,
                onPressed: () => AnimeUserRateBottomSheet.show(
                  context,
                  anime: anime,
                  update: true,
                ),
              ),
              _ActionItem(
                title: 'Хронология',
                icon: Icons.playlist_play_rounded, //list_rounded
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AnimeFranchisePage(
                      id: anime.id!,
                      name:
                          (anime.russian == '' ? anime.name : anime.russian) ??
                              '',
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),
              if (anime.topicId != null && anime.topicId != 0)
                _ActionItem(
                  title: 'Обсуждение',
                  icon: Icons.forum_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          CommentsPage(
                        topicId: anime.topicId!,
                        name: (anime.russian == ''
                                ? anime.name
                                : anime.russian) ??
                            '',
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  ),
                ),
              _ActionItem(
                title: 'Похожее',
                icon: Icons.join_inner,
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        SimilarAnimesPage(
                      animeId: anime.id!,
                      name:
                          (anime.russian == '' ? anime.name : anime.russian) ??
                              '',
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),
              _ActionItem(
                title: 'Ссылки',
                icon: Icons.link,
                onPressed: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        ExternalLinksWidget(
                      animeId: anime.id!,
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),
              const SizedBox(
                width: 8.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserRateItem extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onPressed;

  const _UserRateItem(
    this.anime, {
    // ignore: unused_element
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(
      context,
      status: anime.userRate?.status ?? '',
      dark: context.isDarkThemed,
    );

    return ActionChip(
      onPressed: onPressed,
      shadowColor: Colors.transparent,
      //padding: const EdgeInsets.all(6),
      side: BorderSide(
        width: 1,
        color: color?.withOpacity(0.4) ??
            context.colorScheme.outline.withOpacity(0.6),
      ),
      labelStyle: context.textTheme.bodyMedium?.copyWith(
        color: color ?? context.colorScheme.onBackground,
      ),
      avatar: Icon(
        _getIcon(anime.userRate?.status ?? ''),
        color: color ?? context.colorScheme.onBackground,
      ),
      label: Text(
        anime.userRate != null
            ? _getStatus(anime.userRate!.status ?? '')
            : 'Добавить в список', // Добавить в список    Не смотрю
      ),
    );
  }

  static Color? _getColor(BuildContext ctx,
      {required String status, required bool dark}) {
    switch (status) {
      case 'planned':
        return dark ? Colors.lime.shade200 : Colors.lime.shade800;
      case 'completed':
        return dark ? Colors.green.shade200 : Colors.green.shade600;
      case 'watching':
        return dark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade600;
      case 'rewatching':
        return dark ? Colors.deepPurple.shade200 : Colors.deepPurple.shade600;
      case 'dropped':
        return dark ? Colors.red.shade200 : Colors.red.shade600;
      case 'on_hold':
        return dark ? Colors.blue.shade200 : Colors.blue.shade600;

      default:
        return null;
    }
  }

  String _getStatus(String value) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Смотрю',
      'rewatching': 'Пересматриваю',
      'completed': 'Просмотрено',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    String add;

    switch (anime.userRate?.status) {
      case 'watching' || 'rewatching' || 'on_hold':
        add = ' • ${anime.userRate?.episodes}/${anime.episodes}';
        break;
      case 'completed' || 'dropped':
        add = ' • ${anime.userRate?.score} ★';
        break;
      default:
        add = '';
    }

    status = map[value] ?? '';

    return status + add;
  }

  static IconData _getIcon(String value) {
    IconData icon;

    const map = {
      'planned': Icons.event_available_rounded,
      'watching': Icons.remove_red_eye_rounded,
      'rewatching': Icons.refresh_rounded,
      'completed': Icons.done_all_rounded,
      'on_hold': Icons.pause_rounded,
      'dropped': Icons.close_rounded
    };

    icon = map[value] ?? Icons.bookmark_add_rounded;
    //Icons.add_rounded;

    return icon;
  }
}

class _ActionItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ActionItem({
    // ignore: unused_element
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      shadowColor: Colors.transparent,
      //padding: const EdgeInsets.all(6),
      side: BorderSide(
        width: 1,
        color: context.colorScheme.outline.withOpacity(0.6),
      ),
      labelStyle: context.textTheme.bodyMedium
          ?.copyWith(color: context.colorScheme.onBackground),
      avatar: Icon(
        icon,
        color: context.colorScheme.onBackground,
      ),
      label: Text(title),
    );
  }
}
