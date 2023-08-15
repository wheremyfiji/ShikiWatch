import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../providers/manga_details_provider.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/manga_card.dart';

class MangaSimilarPage extends ConsumerWidget {
  final int mangaId;

  const MangaSimilarPage(this.mangaId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarManga = ref.watch(similarTitlesMangaProvider(mangaId));

    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar.large(
                forceElevated: innerBoxIsScrolled,
                automaticallyImplyLeading: false,
                leading: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                title: const Text(
                  'Похожее',
                ),
              ),
            ];
          },
          body: similarManga.when(
            data: (data) {
              if (data.isEmpty) {
                return Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Σ(ಠ_ಠ)',
                            textAlign: TextAlign.center,
                            style: context.textTheme.displayMedium,
                          ),
                          Text(
                            'Похоже тут пусто..',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Назад',
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              }
              return CustomScrollView(
                shrinkWrap: false,
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final manga = data.toList()[index];

                          return MangaCardEx(manga);
                        },
                        childCount: data.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 140,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                    ),
                  ),
                ],
              );
            },
            error: (err, stack) => CustomErrorWidget(err.toString(),
                () => ref.refresh(similarTitlesMangaProvider(mangaId))),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
