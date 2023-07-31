import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/anime_source.dart';
import '../../../providers/settings_provider.dart';

import 'setting_option.dart';

class AnimeSourceOption extends ConsumerWidget {
  const AnimeSourceOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnimeSource animeSource =
        ref.watch(settingsProvider.select((settings) => settings.animeSource));

    return SettingsOption(
      title: 'Источник для поиска серий',
      subtitle: animeSource.name,
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
                    'Выбор источника для поиска серий',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...AnimeSource.values
                    .map(
                      (e) => RadioListTile(
                        value: e,
                        activeColor: Theme.of(context).colorScheme.primary,
                        groupValue: animeSource,
                        onChanged: (value) async {
                          if (value == null) {
                            return;
                          }

                          await ref
                              .read(settingsProvider.notifier)
                              .setAnimeSource(value);

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
