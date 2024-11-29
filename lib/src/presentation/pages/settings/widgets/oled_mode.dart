import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class OledModeOption extends ConsumerWidget {
  const OledModeOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool oledMode =
        ref.watch(settingsProvider.select((settings) => settings.oledMode));

    return SwitchListTile(
      title: Text(
        'OLED-тема',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Полностью чёрная тема',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: oledMode,
      onChanged: (value) async {
        await ref.read(settingsProvider.notifier).setOledMode(value);
      },
    );
  }
}
