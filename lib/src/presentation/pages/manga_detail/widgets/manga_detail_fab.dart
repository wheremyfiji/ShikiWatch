import 'package:flutter/material.dart';

import '../../../../domain/models/manga_ranobe.dart';
import '../../../../domain/models/manga_short.dart';
import 'user_rate_widget.dart';

class MangaDetailFAB extends StatelessWidget {
  final MangaRanobe data;
  final MangaShort manga;

  const MangaDetailFAB({super.key, required this.data, required this.manga});

  String getStatus(String value, int? c) {
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

    return (c != 0 && value == 'watching') ? '$status (Глава $c)' : status;
  }

  IconData getIcon(String value) {
    IconData icon;

    const map = {
      'planned': Icons.event_available,
      'watching': Icons.auto_stories,
      'rewatching': Icons.refresh,
      'completed': Icons.done_all,
      'on_hold': Icons.pause,
      'dropped': Icons.close
    };

    icon = map[value] ?? Icons.edit;

    return icon;
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
        ),
        useRootNavigator: true,
        isScrollControlled: true,
        enableDrag: false,
        useSafeArea: true,
        builder: (context) {
          return SafeArea(
            child: MangaUserRateBottomSheet(
              manga: manga,
              data: data,
            ),
          );
        },
      ),
      label: data.userRate == null
          ? const Text('Добавить в список')
          : Text(getStatus(
              data.userRate!.status ?? 'Изменить', data.userRate!.chapters)),
      icon: data.userRate == null
          ? const Icon(Icons.add)
          : Icon(getIcon(data.userRate!.status ?? '')),
    );
  }
}
