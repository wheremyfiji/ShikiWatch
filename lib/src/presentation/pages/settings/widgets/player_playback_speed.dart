import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/settings_provider.dart';
import 'setting_option.dart';

const List<double> _playbackRates = <double>[
  0.25,
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2.0,
];

class PlayerPlaybackSpeedOption extends ConsumerWidget {
  const PlayerPlaybackSpeedOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double speed =
        ref.watch(settingsProvider.select((settings) => settings.playerSpeed));

    return SettingsOption(
      title: 'Скорость воспроизведения',
      subtitle: '${speed}x',
      onTap: () => showModalBottomSheet(
        useRootNavigator: true,
        showDragHandle: true,
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
        ),
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ListTile(
                  title: Text(
                    'Скорость воспроизведения в плеере',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ..._playbackRates
                    .map(
                      (e) => RadioListTile(
                        value: e,
                        activeColor: Theme.of(context).colorScheme.primary,
                        groupValue: speed,
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }

                          await ref
                              .read(settingsProvider.notifier)
                              .setPlayerSpeed(value);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        title: Text(
                          '${e}x',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}
