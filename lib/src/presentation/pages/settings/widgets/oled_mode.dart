import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../providers/settings_provider.dart';

class OledModeOption extends ConsumerWidget {
  const OledModeOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool oledMode =
        ref.watch(settingsProvider.select((settings) => settings.oledMode));

    return SwitchListTile(
      title: const Text('AMOLED-тема'),
      subtitle: const Text('Полносью чёрная тема'),
      value: oledMode,
      onChanged: (value) async {
        await ref.read(settingsProvider.notifier).setOledMode(value);
      },
    );
  }
}

// class OledModeWidget extends StatelessWidget {
//   const OledModeWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Box<dynamic>>(
//       valueListenable: Hive.box(BoxType.settings.name).listenable(
//         keys: [oledModeKey],
//       ),
//       builder: (context, value, child) {
//         final bool isOled = value.get(
//           oledModeKey,
//           defaultValue: false,
//         );
//         return SwitchListTile(
//           title: const Text('AMOLED-тема'),
//           subtitle: const Text('Полносью чёрная тема'),
//           value: isOled,
//           onChanged: (value) {
//             Hive.box(BoxType.settings.name).put(oledModeKey, value);
//           },
//         );
//       },
//     );
//   }
// }
