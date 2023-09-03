import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

class CurrentThemeOption extends ConsumerWidget {
  const CurrentThemeOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode currentTheme =
        ref.watch(settingsProvider.select((settings) => settings.theme));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Тема приложения',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onBackground,
              ),
            ),
          ),
          Row(
            children: [
              _ThemeCard(
                title: 'Системная',
                icon: Icons.brightness_auto,
                primary: true,
                isSelected: currentTheme == ThemeMode.system,
                onTap: () {
                  if (currentTheme == ThemeMode.system) {
                    return;
                  }

                  ref
                      .read(settingsProvider.notifier)
                      .setTheme(ThemeMode.system);
                },
              ),
              const SizedBox(
                width: 8.0,
              ),
              _ThemeCard(
                title: 'Тёмная',
                icon: Icons.brightness_2,
                primary: false,
                isSelected: currentTheme == ThemeMode.dark,
                onTap: () {
                  if (currentTheme == ThemeMode.dark) {
                    return;
                  }

                  ref.read(settingsProvider.notifier).setTheme(ThemeMode.dark);
                },
              ),
              const SizedBox(
                width: 8.0,
              ),
              _ThemeCard(
                title: 'Светлая',
                icon: Icons.wb_sunny_outlined,
                primary: false,
                isSelected: currentTheme == ThemeMode.light,
                onTap: () {
                  if (currentTheme == ThemeMode.light) {
                    return;
                  }

                  ref.read(settingsProvider.notifier).setTheme(ThemeMode.light);
                },
              ),
            ],
          ),
        ],
      ),
    );

    // return SettingsOption(
    //   title: 'Тема приложения',
    //   subtitle: currentTheme.themeName,
    //   onTap: () => showModalBottomSheet(
    //       useRootNavigator: true,
    //       showDragHandle: true,
    //       useSafeArea: true,
    //       isScrollControlled: true,
    //       context: context,
    //       constraints: BoxConstraints(
    //         maxWidth: MediaQuery.of(context).size.width >= 700
    //             ? 700
    //             : double.infinity,
    //       ),
    //       builder: (context) {
    //         return SafeArea(
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             crossAxisAlignment: CrossAxisAlignment.end,
    //             children: [
    //               ListTile(
    //                 title: Text(
    //                   'Выбор темы приложения',
    //                   style: Theme.of(context).textTheme.titleLarge,
    //                 ),
    //               ),
    //               ...ThemeMode.values
    //                   .map(
    //                     (e) => RadioListTile(
    //                       value: e,
    //                       activeColor: Theme.of(context).colorScheme.primary,
    //                       groupValue: currentTheme,
    //                       onChanged: (theme) async {
    //                         if (theme == null) {
    //                           return;
    //                         }

    //                         await ref
    //                             .read(settingsProvider.notifier)
    //                             .setTheme(theme);

    //                         if (context.mounted) {
    //                           Navigator.pop(context);
    //                         }
    //                       },
    //                       title: Text(
    //                         e.themeName,
    //                         style: TextStyle(
    //                           color: Theme.of(context).colorScheme.onSurface,
    //                         ),
    //                       ),
    //                     ),
    //                   )
    //                   .toList(),
    //             ],
    //           ),
    //         );
    //       }),
    // );
  }
}

class _ThemeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Function() onTap;
  final bool primary;
  final bool isSelected;

  const _ThemeCard({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.primary,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? context.colorScheme.onPrimaryContainer
        : context.colorScheme.onBackground;

    return Expanded(
      flex: primary ? 3 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isSelected ? context.colorScheme.primaryContainer : null,
            border: isSelected
                ? null
                : Border.all(
                    color: context.colorScheme.outline,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
