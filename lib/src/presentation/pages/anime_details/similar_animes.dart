import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../providers/anime_details_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

class SimilarAnimesPage extends ConsumerWidget {
  final int animeId;

  const SimilarAnimesPage({super.key, required this.animeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAnimes = ref.watch(similarTitlesAnimeProvider(animeId));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar.large(
              forceElevated: innerBoxIsScrolled,
              stretch: true,
              title: const Text(
                'Похожее',
              ),
            ),
          ];
        },
        body: similarAnimes.when(
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
                          onPressed: () {
                            context.pop();
                          },
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
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final anime = data.toList()[index];

                        return AnimeTileExp(anime);
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
              () => ref.refresh(similarTitlesAnimeProvider(animeId))),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
