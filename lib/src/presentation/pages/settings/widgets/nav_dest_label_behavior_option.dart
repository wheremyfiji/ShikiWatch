import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/navigation_dest_label_beh_ext.dart';
import '../../../providers/settings_provider.dart';
import 'setting_option.dart';

class NavDestLabelBehaviorOption extends ConsumerWidget {
  const NavDestLabelBehaviorOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NavigationDestinationLabelBehavior navDestLabelBehavior = ref.watch(
        settingsProvider.select((settings) => settings.navDestLabelBehavior));

    return SettingsOption(
      title: 'Подписи в баре навигации',
      subtitle: navDestLabelBehavior.labelBehName,
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
                    'Подписи в баре навигации',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...NavigationDestinationLabelBehavior.values
                    .map(
                      (e) => RadioListTile(
                        value: e,
                        activeColor: Theme.of(context).colorScheme.primary,
                        groupValue: navDestLabelBehavior,
                        onChanged: (mode) async {
                          if (mode == null) {
                            return;
                          }

                          await ref
                              .read(settingsProvider.notifier)
                              .setNavDestLabelBehavior(mode)
                              .then((value) => Navigator.pop(context));
                        },
                        title: Text(
                          e.labelBehName,
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
