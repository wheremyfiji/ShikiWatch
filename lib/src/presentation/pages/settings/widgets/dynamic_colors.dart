import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/target_platform.dart';
import '../../../providers/environment_provider.dart';
import '../../../providers/settings_provider.dart';

class DynamicColorsOption extends ConsumerWidget {
  const DynamicColorsOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    if ((environment.sdkVersion ?? 0) < 31 && !TargetP.instance.isDesktop) {
      return const SizedBox.shrink();
    }

    final bool dynamicColors = ref
        .watch(settingsProvider.select((settings) => settings.dynamicColors));

    return SwitchListTile(
      title: const Text('Динамические цвета'),
      subtitle: TargetP.instance.isDesktop
          ? null
          : const Text('Динамические цвета на основе обоев телефона'),
      value: dynamicColors,
      onChanged: (value) async {
        await ref.read(settingsProvider.notifier).setDynamicColors(value);
      },
    );

    // return ValueListenableBuilder<Box<dynamic>>(
    //   valueListenable: Hive.box(BoxType.settings.name).listenable(
    //     keys: [dynamicThemeKey],
    //   ),
    //   builder: (context, value, child) {
    //     final bool isDynamic = value.get(
    //       dynamicThemeKey,
    //       defaultValue: true,
    //     );
    //     return SwitchListTile(
    //       title: const Text('Динамические цвета'),
    //       subtitle: TargetP.instance.isDesktop
    //           ? null
    //           : const Text('Динамические цвета на основе обоев телефона'),
    //       value: isDynamic,
    //       onChanged: (value) {
    //         Hive.box(BoxType.settings.name).put(dynamicThemeKey, value);
    //       },
    //     );
    //   },
    // );
  }
}
