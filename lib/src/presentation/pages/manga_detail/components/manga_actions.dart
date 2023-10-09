import 'package:flutter/material.dart';

import '../../../../domain/models/manga_ranobe.dart';
import '../../../../domain/models/manga_short.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/shadowed_overflow_decorator.dart';
import '../../comments/comments_page.dart';
import '../manga_links_page.dart';
import '../manga_similar_page.dart';
import '../manga_user_rate.dart';

class MangaActions extends StatelessWidget {
  final MangaShort manga;
  final MangaRanobe data;

  const MangaActions({
    super.key,
    required this.manga,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ShadowedOverflowDecorator(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 8.0,
            children: [
              const SizedBox(
                width: 8.0,
              ),
              _UserRateItem(
                data,
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width >= 700
                        ? 700
                        : double.infinity,
                  ),
                  useRootNavigator: true,
                  isScrollControlled: true,
                  enableDrag: false,
                  useSafeArea: true,
                  elevation: 0,
                  builder: (context) {
                    return SafeArea(
                      child: MangaUserRateBottomSheet(
                        manga: manga,
                        data: data,
                      ),
                    );
                  },
                ),
              ),
              // _ActionItem(
              //   title: 'Хронология',
              //   icon: Icons.playlist_play_rounded,
              //   onPressed: () {},
              // ),
              if (data.topicId != null && data.topicId != 0)
                _ActionItem(
                  title: 'Обсуждение',
                  icon: Icons.forum_rounded,
                  onPressed: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          CommentsPage(
                        topicId: data.topicId!,
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
                        MangaSimilarPage(manga.id!),
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
                        MangaExternalLinksPage(
                      data.id!,
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
  final MangaRanobe manga;
  final VoidCallback? onPressed;

  const _UserRateItem(
    this.manga, {
    // ignore: unused_element
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(
      context,
      status: manga.userRate?.status ?? '',
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
        _getIcon(manga.userRate?.status ?? ''),
        color: color ?? context.colorScheme.onBackground,
      ),
      label: Text(
        manga.userRate != null
            ? _getStatus(manga.userRate!.status ?? '')
            : 'Добавить в список',
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

  static String _getStatus(String value) {
    String status;

    const map = {
      'planned': 'В планах',
      'watching': 'Читаю',
      'rewatching': 'Перечитываю',
      'completed': 'Прочитано',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? '';

    return status;
  }

  static IconData _getIcon(String value) {
    IconData icon;

    const map = {
      'planned': Icons.event_available_rounded,
      'watching': Icons.auto_stories_rounded,
      'rewatching': Icons.refresh_rounded,
      'completed': Icons.done_all_rounded,
      'on_hold': Icons.pause_rounded,
      'dropped': Icons.close_rounded
    };

    icon = map[value] ?? Icons.bookmark_add_rounded;

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
