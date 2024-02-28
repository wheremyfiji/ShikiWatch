import 'package:flutter/material.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../../domain/models/anime_database.dart';

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
      //padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0.0),
      sliver: SliverToBoxAdapter(
        child: Card(
          margin: const EdgeInsets.all(0.0),
          shadowColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Последнее просмотренное',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Text('${studio.name} • Серия ${episode.nubmer.toString()}'),
                if (episode.timeStamp != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      episode.timeStamp!,
                      style: TextStyle(
                        color:
                            context.colorScheme.onBackground.withOpacity(0.8),
                      ),
                    ),
                  ),
                const SizedBox(
                  height: 8.0,
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
