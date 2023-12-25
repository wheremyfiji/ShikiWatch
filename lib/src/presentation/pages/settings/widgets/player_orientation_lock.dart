import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class PlayerOrientationLockOption extends ConsumerWidget {
  const PlayerOrientationLockOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerOrientationLock = ref.watch(
        settingsProvider.select((settings) => settings.playerOrientationLock));

    return SwitchListTile(
      title: Text(
        'Блокировка ориентации',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Принудительный ландшафтный режим в плеере',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: playerOrientationLock,
      onChanged: (value) =>
          ref.read(settingsProvider.notifier).setPlayerOrientationLock(value),
    );
  }
}
