import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class PlayerAndroidNewAudioBackendOption extends ConsumerWidget {
  const PlayerAndroidNewAudioBackendOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerAndroidNewAudioBackend = ref.watch(settingsProvider
        .select((settings) => settings.playerAndroidNewAudioBackend));

    return SwitchListTile(
      title: Text(
        'Использовать aaudio backend',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Может помочь при проблемах с аудио во время воспроизведения',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: playerAndroidNewAudioBackend,
      onChanged: (value) => ref
          .read(settingsProvider.notifier)
          .setPlayerAndroidNewAudioBackend(value),
    );
  }
}
