import 'package:flutter/material.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../domain/models/anime_database.dart';

class LatestStudio extends StatelessWidget {
  final Studio studio;
  final VoidCallback onContinue;

  const LatestStudio({
    super.key,
    required this.studio,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final episode = studio.episodes!.last;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      sliver: SliverToBoxAdapter(
        child: Card(
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Последнее просмотренное',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text('${studio.name} • Серия ${episode.nubmer.toString()}'),
                if (episode.timeStamp != null) Text(episode.timeStamp!),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    FilledButton(
                      onPressed: onContinue,
                      child: const Text('Продолжить'),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
