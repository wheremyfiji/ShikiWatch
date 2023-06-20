import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/settings_provider.dart';

class PlayerDiscordRpcOption extends ConsumerWidget {
  const PlayerDiscordRpcOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool playerDiscordRpc = ref.watch(
        settingsProvider.select((settings) => settings.playerDiscordRpc));

    return SwitchListTile(
      title: const Text('Discord RPC'),
      subtitle: const Text('Отображать текущую активность в Discord'),
      value: playerDiscordRpc,
      onChanged: (value) async {
        await ref.read(settingsProvider.notifier).setPlayerDiscordRpc(value);
      },
    );
  }
}
