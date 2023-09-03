import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class PlayerDiscordRpcOption extends ConsumerWidget {
  const PlayerDiscordRpcOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerDiscordRpc = ref.watch(
        settingsProvider.select((settings) => settings.playerDiscordRpc));

    return SwitchListTile(
      title: Text(
        'Discord RPC',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Отображать текущую активность в Discord',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: playerDiscordRpc,
      onChanged: (value) =>
          ref.read(settingsProvider.notifier).setPlayerDiscordRpc(value),
    );
  }
}
