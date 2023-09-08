import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../../utils/app_utils.dart';
import '../../../providers/environment_provider.dart';
import '../../../providers/settings_provider.dart';

class DynamicColorsOption extends ConsumerWidget {
  const DynamicColorsOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentProvider);

    if ((environment.sdkVersion ?? 0) < 31 && !AppUtils.instance.isDesktop) {
      return const SizedBox.shrink();
    }

    final bool dynamicColors = ref
        .watch(settingsProvider.select((settings) => settings.dynamicColors));

    return SwitchListTile(
      title: Text(
        'Динамические цвета',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: AppUtils.instance.isDesktop
          ? null
          : Text(
              'Динамические цвета на основе обоев телефона',
              style: TextStyle(
                color: context.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
      value: dynamicColors,
      onChanged: (value) async {
        await ref.read(settingsProvider.notifier).setDynamicColors(value);
      },
    );
  }
}
