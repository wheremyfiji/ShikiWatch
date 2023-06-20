import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/theme_mode.dart';
import '../../../providers/settings_provider.dart';
import 'setting_option.dart';

class CurrentThemeOption extends ConsumerWidget {
  const CurrentThemeOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode currentTheme =
        ref.watch(settingsProvider.select((settings) => settings.theme));

    return SettingsOption(
      title: 'Тема приложения',
      subtitle: currentTheme.themeName,
      onTap: () => showModalBottomSheet(
          useRootNavigator: true,
          showDragHandle: true,
          context: context,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width >= 700
                ? 700
                : double.infinity,
          ),
          builder: (context) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ListTile(
                    title: Text(
                      'Выбор темы приложения',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ...ThemeMode.values
                      .map(
                        (e) => RadioListTile(
                          value: e,
                          activeColor: Theme.of(context).colorScheme.primary,
                          groupValue: currentTheme,
                          onChanged: (theme) async {
                            if (theme == null) {
                              return;
                            }

                            await ref
                                .read(settingsProvider.notifier)
                                .setTheme(theme);

                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          title: Text(
                            e.themeName,
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
          }),
    );
  }
}
