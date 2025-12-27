import 'package:flutter/material.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../services/updater/update_service.dart';
import '../providers/environment_provider.dart';

class AppUpdateBottomSheet extends ConsumerWidget {
  final AppRelease release;

  const AppUpdateBottomSheet(this.release, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentVersion = ref.watch(environmentProvider).appVersion;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Доступно обновление',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Text('Текущая версия: $currentVersion'),
          Text('Новая версия: ${release.tag.replaceAll('v', '')}'),
          if (release.asset != null)
            Text(
              'Размер: ${(release.asset!.size / (1024 * 1024)).toStringAsFixed(2)} MB',
            ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            width: double.infinity,
            child: Card(
              margin: const EdgeInsets.all(0),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: MarkdownBody(
                  data: release.description,
                  onTapLink: (text, href, title) {
                    if (href == null) {
                      return;
                    }

                    launchUrlString(href, mode: LaunchMode.externalApplication);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              child: release.asset == null
                  ? FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => launchUrlString(
                        release.url,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text('Перейти к загрузке'),
                    )
                  : FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () => launchUrlString(
                        release.asset!.browserDownloadUrl,
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text('Загрузить'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(
      {required BuildContext context, required AppRelease release}) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      useRootNavigator: true,
      showDragHandle: true,
      builder: (_) => SafeArea(child: AppUpdateBottomSheet(release)),
    );
  }
}
