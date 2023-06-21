import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../services/updater/update_service.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/app_update_bottom_sheet.dart';

class SettingsHeader extends ConsumerWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(appReleaseProvider);

    return release.when(
      data: (data) {
        if (data == null) {
          return const SizedBox.shrink();
        }

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          // elevation: 0,
          // color: Theme.of(context).colorScheme.background,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(12),
          //   side: BorderSide(
          //     color: Theme.of(context).colorScheme.surfaceVariant,
          //     width: 1,
          //   ),
          // ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Доступна новая версия приложения',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 8,
                ),
                Text('Новая версия: ${data.tag.replaceAll('v', '')}'),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => AppUpdateBottomSheet.show(
                          context: context, release: data),
                      child: const Text('Подробнее'),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    FilledButton(
                      onPressed: () => launchUrlString(
                        data.asset.browserDownloadUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                      child: const Text('Загрузить'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
