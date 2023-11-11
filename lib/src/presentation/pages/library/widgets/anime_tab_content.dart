import 'package:flutter/material.dart';

import '../../../../domain/enums/library_layout_mode.dart';
import '../../../../domain/models/user_anime_rates.dart';
import '../../../widgets/anime_card.dart';

class AnimeTabContent extends StatelessWidget {
  final List<UserAnimeRates> data;
  final LibraryLayoutMode currentLayout;
  final Future<void> Function() onRefresh;
  final Key pageStorageKey;

  const AnimeTabContent({
    super.key,
    required this.data,
    required this.currentLayout,
    required this.onRefresh,
    required this.pageStorageKey,
  });

  @override
  Widget build(BuildContext context) {
    // TODO че это тут забыло вообще
    data.sort((a, b) {
      String adate = a.updatedAt!;
      String bdate = b.updatedAt!;
      return -adate.compareTo(bdate);
    });

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: pageStorageKey,
        slivers: [
          if (currentLayout != LibraryLayoutMode.compactList)
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 16.0),
            ),
          switch (currentLayout) {
            LibraryLayoutMode.compactList => SliverList.builder(
                itemCount: data.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
                itemBuilder: (context, index) {
                  final animeUserRate = data[index];

                  return AnimeCompactListTile(animeUserRate);
                },
              ),
            LibraryLayoutMode.list => SliverList.builder(
                itemCount: data.length,
                addAutomaticKeepAlives: false,
                addRepaintBoundaries: false,
                addSemanticIndexes: false,
                itemBuilder: (context, index) {
                  final animeUserRate = data[index];

                  final lastElement = index == (data.length - 1);

                  return Padding(
                    padding:
                        EdgeInsets.fromLTRB(16, 0, 16, lastElement ? 16 : 8),
                    child: AnimeListTile(animeUserRate),
                  );
                },
              ),
            LibraryLayoutMode.grid => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: false,
                    addSemanticIndexes: false,
                    childCount: data.length,
                    (context, index) {
                      final animeUserRate = data[index];

                      return AnimeCard(animeUserRate);
                    },
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 140,
                    childAspectRatio: 0.55,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                ),
              ),
          },
          SliverPadding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
    );
  }
}
