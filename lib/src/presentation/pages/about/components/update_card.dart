import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../services/updater/update_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/extensions/buildcontext.dart';
import '../../../widgets/app_update_bottom_sheet.dart';

class UpdateCard extends ConsumerWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (AppUtils.instance.isDesktop) {
      return const SizedBox.shrink();
    }

    final release = ref.watch(appReleaseProvider);

    return release.when(
      data: (data) {
        if (data == null) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: ElevatedButton.icon(
              onPressed: () => ref.invalidate(appReleaseProvider),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
              ),
              icon: const Icon(Icons.done),
              label: const Text('Установлена последняя версия'),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.system_update_rounded),
                    ),
                    Expanded(
                      child: Text(
                        'Доступно обновление',
                        style: context.textTheme.titleLarge,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text('Новая версия: ${data.tag.replaceFirst('v', '')}'),
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
      loading: () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: ElevatedButton.icon(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          icon: Container(
            width: 24,
            height: 24,
            padding: const EdgeInsets.all(2.0),
            child: const CircularProgressIndicator(),
          ),
          label: const Text('Проверка обновлений..'),
        ),
      ),
      error: (error, stackTrace) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: ElevatedButton.icon(
          onPressed: () => ref.invalidate(appReleaseProvider),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
          icon: const Icon(Icons.update),
          label: const Text('Проверить наличие обновлений'),
        ),
      ),
      //error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }
}
