import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/library_state.dart';
import '../../../providers/settings_provider.dart';
import 'setting_option.dart';

class LibraryStartFragmentOption extends ConsumerWidget {
  const LibraryStartFragmentOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LibraryFragmentMode currentFragment = ref
        .watch(settingsProvider.select((settings) => settings.libraryFragment));

    return SettingsOption(
      title: 'Раздел по умолчанию', // рял, а кого раздел то.. одевайся давай
      subtitle: currentFragment.name,
      onTap: () => showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        useRootNavigator: true,
        isScrollControlled: true,
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
                    'Выбор раздела библиотеки по умолчанию',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...LibraryFragmentMode.values
                    .map(
                      (e) => RadioListTile(
                        value: e,
                        activeColor: Theme.of(context).colorScheme.primary,
                        groupValue: currentFragment,
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }

                          await ref
                              .read(settingsProvider.notifier)
                              .setLibraryStartFragment(value);

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
