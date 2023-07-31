import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/library_layout_mode.dart';
import '../../../providers/settings_provider.dart';

import 'setting_option.dart';

class LibraryLayoutOption extends ConsumerWidget {
  const LibraryLayoutOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LibraryLayoutMode libraryLayout = ref
        .watch(settingsProvider.select((settings) => settings.libraryLayout));

    return SettingsOption(
      title: 'Способ отображения',
      subtitle: libraryLayout.name,
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
                    'Выбор способа отображения карточек аниме',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...LibraryLayoutMode.values
                    .map(
                      (e) => RadioListTile(
                        value: e,
                        activeColor: Theme.of(context).colorScheme.primary,
                        groupValue: libraryLayout,
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }

                          await ref
                              .read(settingsProvider.notifier)
                              .setLibraryLayout(value);

                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        title: Text(
                          e.name,
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
