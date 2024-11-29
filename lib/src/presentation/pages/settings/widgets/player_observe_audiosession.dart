import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class PlayerObserveAudioSessionOption extends ConsumerWidget {
  const PlayerObserveAudioSessionOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerObserveAudioSession = ref.watch(settingsProvider
        .select((settings) => settings.playerObserveAudioSession));

    return SwitchListTile(
      title: Text(
        'Реакция на уведомления',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Приглушение звука или пауза в плеере при уведомлениях',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: playerObserveAudioSession,
      onChanged: (value) => ref
          .read(settingsProvider.notifier)
          .setPlayerObserveAudioSession(value),
    );
  }
}
