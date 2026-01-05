import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';
import '../../player/pip_provider.dart';

class PlayerAutoPipOption extends ConsumerWidget {
  const PlayerAutoPipOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerAutoPip = ref
        .watch(settingsProvider.select((settings) => settings.playerAutoPip));

    final isPipAvailable = ref.watch(pipAvailabilityProvider);

    if (!isPipAvailable) {
      return const SizedBox.shrink();
    }

    return SwitchListTile(
      title: Text(
        'Авто-переход в режим PiP',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Автоматически переходить в режим PiP при сворачивании приложения',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: playerAutoPip,
      onChanged: (value) =>
          ref.read(settingsProvider.notifier).setPlayerAutoPip(value),
    );
  }
}
