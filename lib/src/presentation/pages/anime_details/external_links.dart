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
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Ссылки'),
          ),
          ...links.when(
            data: (data) => [
              SliverList.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final link = data.toList()[index];
                  final enable = link.url != null;
                  return ListTile(
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
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 16.0,
                ),
              ),
            ],
            error: (error, stackTrace) => [
              SliverFillRemaining(
                child: CustomErrorWidget(
                  error.toString(),
                  () => ref.refresh(externalLinksAnimeProvider(animeId)),
                ),
              ),
            ],
            loading: () => [
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
