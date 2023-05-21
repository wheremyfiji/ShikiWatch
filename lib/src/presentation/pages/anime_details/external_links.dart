import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:shikidev/src/utils/extensions/string_ext.dart';

import '../../providers/anime_details_provider.dart';
import '../../widgets/error_widget.dart';

class ExternalLinksWidget extends ConsumerWidget {
  final int animeId;

  const ExternalLinksWidget({super.key, required this.animeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksAnimeProvider(animeId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ссылки'),
      ),
      body: links.when(
        data: (data) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final link = data.toList()[index];
                  final enable = link.url != null;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.all(0),
                      child: ListTile(
                        enabled: enable,
                        title: Text(
                          link.kind?.replaceAll('_', ' ').capitalizeFirst ?? '',
                        ),
                        trailing: const Icon(
                          Icons.open_in_browser,
                        ),
                        onTap: () {
                          launchUrlString(
                            link.url!,
                            mode: LaunchMode.externalApplication,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        error: (err, stack) => CustomErrorWidget(err.toString(),
            () => ref.refresh(externalLinksAnimeProvider(animeId))),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
