import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class PlayerLongPressSeekOption extends ConsumerWidget {
  const PlayerLongPressSeekOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool longPressSeek = ref.watch(
        settingsProvider.select((settings) => settings.playerLongPressSeek));

    return SwitchListTile(
      title: Text(
        'Быстрая перемотка',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Ускорение 2x при долгом нажатии',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: longPressSeek,
      onChanged: (bool value) =>
          ref.read(settingsProvider.notifier).setPlayerLongPressSeek(value),
    );
  }
}
