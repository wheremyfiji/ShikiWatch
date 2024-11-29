import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';
import '../../anime_details/rating_dialog.dart';

class ShikiAllowExpContentOption extends ConsumerWidget {
  const ShikiAllowExpContentOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool shikiAllowExpContent = ref.watch(
        settingsProvider.select((settings) => settings.shikiAllowExpContent));

    return SwitchListTile(
      title: Text(
        'Разрешить 18+ контент',
        style: TextStyle(
          color: context.colorScheme.onBackground,
        ),
      ),
      subtitle: Text(
        'Для поиска и воспроизведения в плеере',
        style: TextStyle(
          color: context.colorScheme.onBackground.withOpacity(0.8),
        ),
      ),
      value: shikiAllowExpContent,
      onChanged: (value) async {
        if (!shikiAllowExpContent) {
          bool? dialogValue = await showDialog<bool>(
            barrierDismissible: false,
            context: context,
            builder: (context) => const RatingDialog(),
          );

          if (dialogValue == null || !dialogValue) {
            return;
          }
        }

        ref.read(settingsProvider.notifier).setShikiAllowExpContent(value);
      },
    );
  }
}
