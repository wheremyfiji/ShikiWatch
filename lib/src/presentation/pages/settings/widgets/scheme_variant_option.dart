import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/color_scheme_variant.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../providers/settings_provider.dart';

import 'setting_option.dart';

class SchemeVariantOption extends ConsumerWidget {
  const SchemeVariantOption({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorSchemeVariant colorSchemeVariant = ref.watch(
        settingsProvider.select((settings) => settings.colorSchemeVariant));

    return SettingsOption(
      title: 'Вариант цветовой гаммы',
      subtitle: colorSchemeVariant.label,
      onTap: () => showModalBottomSheet(
          useRootNavigator: true,
          showDragHandle: true,
          useSafeArea: true,
          isScrollControlled: true,
          context: context,
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width >= 700
                ? 700
                : double.infinity,
          ),
          builder: (context) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ListTile(
                      title: Text(
                        'Выбор варианта цветовой гаммы',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ...ColorSchemeVariant.values
                        .map(
                          (e) => RadioListTile(
                            value: e,
                            activeColor: Theme.of(context).colorScheme.primary,
                            groupValue: colorSchemeVariant,
                            onChanged: (variant) async {
                              if (variant == null) {
                                return;
                              }

                              await ref
                                  .read(settingsProvider.notifier)
                                  .setColorSchemeVariant(variant);

                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            },
                            title: Text(
                              e.label,
                              style: TextStyle(
                                color: context.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
