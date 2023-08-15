import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../utils/extensions/string_ext.dart';
import '../../providers/manga_details_provider.dart';
import '../../widgets/error_widget.dart';

class MangaExternalLinksPage extends ConsumerWidget {
  final int mangaId;

  const MangaExternalLinksPage(this.mangaId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(externalLinksMangaProvider(mangaId));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              title: const Text('Ссылки'),
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
                    () => ref.refresh(externalLinksMangaProvider(mangaId)),
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
