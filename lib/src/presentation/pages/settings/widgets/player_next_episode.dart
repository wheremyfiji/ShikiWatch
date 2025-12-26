import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class PlayerNextEpisodeOption extends ConsumerWidget {
  const PlayerNextEpisodeOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerNextEpisode = ref.watch(
        settingsProvider.select((settings) => settings.playerNextEpisode));

    return SwitchListTile(
      title: Text(
        'Переход к след. эпизоду',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Автоматически воспроизводить следующий эпизод',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: playerNextEpisode,
      onChanged: (value) =>
          ref.read(settingsProvider.notifier).setPlayerNextEpisode(value),
    );
  }
}
