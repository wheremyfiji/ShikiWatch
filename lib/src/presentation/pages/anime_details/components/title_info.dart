import 'package:flutter/material.dart';

import '../../../../domain/models/anime.dart';
import '../../../../utils/shiki_utils.dart';

class TitleInfo extends StatelessWidget {
  final Anime anime;
  final String duration;
  final String? nextEp;

  const TitleInfo(
    this.anime, {
    super.key,
    required this.duration,
    required this.nextEp,
  });

  @override
  Widget build(BuildContext context) {
    final date = _getDate(anime.airedOn, anime.releasedOn);
    final year = date?[0];
    final season = date?[1];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoItem(
            'Тип: ',
            '${getKind(anime.kind!)} • ${getStatus(anime.status!)}',
          ),
          if (date != null)
            _InfoItem(
              'Сезон: ',
              '$season $year',
            ),
          if (anime.episodes != null && anime.episodesAired != null)
            anime.status == 'released'
                ? _InfoItem(
                    'Эпизоды: ',
                    '${anime.episodes!} эп. по ~$duration мин.',
                  )
                : _InfoItem(
                    'Эпизоды: ',
                    '${anime.episodesAired!} из ${anime.episodes! == 0 ? '?' : '${anime.episodes!}'} эп. по ~$duration мин.',
                  ),
          if (nextEp != null && nextEp != '')
            _InfoItem(
              'След. серия: ',
              '$nextEp',
            ),
        ],
      ),
    );
  }

  List<String>? _getDate(String? airedOn, String? releasedOn) {
    String? date = airedOn;

    if (date == null) {
      return null;
    }

    final splitted = date.split('-');
    var month = int.parse(splitted[1]);

    return [splitted[0], getSeason(month)];
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
