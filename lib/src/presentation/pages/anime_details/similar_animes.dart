import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../utils/extensions/buildcontext.dart';
import '../../providers/anime_details_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

class SimilarAnimesPage extends ConsumerWidget {
  final int animeId;
  final String name;

  const SimilarAnimesPage({
    super.key,
    required this.animeId,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final similarAnimes = ref.watch(similarTitlesAnimeProvider(animeId));

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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Похожее',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: context.theme.colorScheme.onBackground
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            ...similarAnimes.when(
              data: (data) {
                if (data.isEmpty) {
                  return [
                    SliverFillRemaining(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Σ(ಠ_ಠ)',
                            textAlign: TextAlign.center,
                            style: context.textTheme.displayMedium,
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Похоже тут пусто..',
                            textAlign: TextAlign.center,
                            style: context.textTheme.bodySmall?.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  ];
                }
                return [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      context.padding.bottom,
                    ),
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
                ];
              },
              loading: () => [
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              ],
              error: (err, stack) => [
                SliverFillRemaining(
                  child: CustomErrorWidget(
                    err.toString(),
                    () => ref.refresh(similarTitlesAnimeProvider(animeId)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
