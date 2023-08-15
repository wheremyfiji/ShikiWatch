import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/manga_ranobe.dart';
import '../../../../utils/shiki_utils.dart';

class MangaInfoWidget extends StatelessWidget {
  final MangaRanobe data;

  const MangaInfoWidget(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    final airedDateTime = format.parse(data.airedOn ?? '');
    final airedString = DateFormat.yMMMM().format(airedDateTime); // yMMM
    final releasedDateTime = format.parse(data.releasedOn ?? '1970-01-01');
    final releasedString = DateFormat.yMMMM().format(releasedDateTime);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoItem(
            'Тип: ',
            '${getKind(data.kind!)} • ${getStatus(data.status!)}',
          ),
          if (data.status == 'ongoing')
            _InfoItem(
              'Выходит: ',
              airedString,
            ),
          if (data.status == 'released')
            _InfoItem(
              'Издано: ',
              data.releasedOn == null ? airedString : releasedString,
            ),
          if (data.volumes != null && data.volumes != 1 && data.volumes != 0)
            _InfoItem(
              'Тома: ',
              '${data.volumes}',
            ),
          if (data.volumes != null && data.volumes != 0)
            _InfoItem(
              'Главы: ',
              '${data.chapters}',
            ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoItem(this.title, this.subtitle, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: subtitle),
        ],
      ),
    );
  }
}
