import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../providers/anime_details_provider.dart';
import '../../../utils/extensions/string_ext.dart';
import '../../widgets/error_widget.dart';

class ExternalLinksWidget extends ConsumerWidget {
  final int animeId;

  const ExternalLinksWidget({super.key, required this.animeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksAnimeProvider(animeId));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverAppBar(
              title: Text('Ссылки'),
              pinned: true,
            ),
            ...links.when(
              data: (data) => [
                SliverList.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final link = data.toList()[index];
                    final enable = link.url != null;

                    final url = _parseUrl(link.url);
                    final cleanUrl = _cleanUrl(url);

                    return ListTile(
                      enabled: enable,
                      title: Text(
                        link.kind?.replaceAll('_', ' ').capitalizeFirst ?? '',
                      ),
                      subtitle: url == null
                          ? null
                          : Text(
                              cleanUrl ?? '',
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
      ),
    );
  }
}

String? _cleanUrl(String? url) {
  if (url == null) {
    return null;
  }

  return url.replaceFirst('https://', '').replaceFirst('www.', '');
}

String? _parseUrl(String? url) {
  if (url == null) {
    return null;
  }

  if (url.startsWith('http://')) {
    return url.replaceFirst('http://', 'https://');
  }

  return url;
}
