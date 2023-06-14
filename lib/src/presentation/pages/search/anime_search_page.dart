import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../domain/enums/search_state.dart';
import '../../../domain/models/animes.dart';
import '../../providers/anime_search_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

final searchTypeProvider = StateProvider<SearchState>((ref) {
  return SearchState.anime;
}, name: 'searchTypeProvider');

class AnimeSearchPage extends ConsumerWidget {
  final int? studioId;
  final int? genreId;

  const AnimeSearchPage({super.key, this.studioId, this.genreId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t =
        SearchPageParameters(studioId: studioId ?? 0, genreId: genreId ?? 0);
    final controller = ref.watch(animeSearchProvider(t));

    final seatchTypeState = ref.watch(searchTypeProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.pushNamed('search_filters', extra: t),
          icon: const Icon(Icons.tune), //tune  filter_list
          label: const Text('Фильтры'),
        ),
        appBar: AppBar(
          title: TextField(
            controller: controller.textEditingController,
            //autofocus: true,
            focusNode: controller.focusNode,
            onChanged: controller.onSearchChanged,
            onSubmitted: (value) {
              controller.onSearchSubmitted(value);
            },
            decoration: InputDecoration(
              filled: false,
              //contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              hintText: seatchTypeState.searchHintText,
              suffixIcon: controller.textEditingController.text.isNotEmpty
                  ? GestureDetector(
                      child: const Icon(Icons.close),
                      onTap: () {
                        controller.clearQuery();
                      },
                    )
                  : null,
            ),
          ),
          bottom: AppBar(
            automaticallyImplyLeading: false,
            primary: false,
            title: const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SearchTypeChips(),
            ),
          ),
          // actions: const [
          //   Padding(
          //     padding: EdgeInsets.all(8.0),
          //     child: SearchTypeWidget(),
          //   ),
          // ],
        ),
        body: Builder(
          builder: (context) {
            if (controller.textEditingController.text.isEmpty &&
                controller.showHistory) {
              return AnimeSearchHistory(
                history: controller.searchHistory,
                search: (p0) {
                  FocusScope.of(context).unfocus();
                  controller.onHistoryTap(p0);
                },
                clear: () => controller.clearHistory(),
              );
            }
            return CustomScrollView(
              key: const PageStorageKey<String>('SearchPageResult'),
              slivers: [
                if (controller.filterCount.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        'Кол-во фильтров: ${controller.filterCount.length}',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: 14,
                            ),
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: PagedSliverGrid<int, Animes>(
                    addAutomaticKeepAlives: true,
                    showNewPageErrorIndicatorAsGridChild: false,
                    //showNoMoreItemsIndicatorAsGridChild: false,
                    pagingController: controller.pageController,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 140,
                      childAspectRatio: 0.55,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<Animes>(
                      itemBuilder: (context, item, index) {
                        return AnimeTileExp(item);
                      },
                      firstPageErrorIndicatorBuilder: (context) {
                        return CustomErrorWidget(
                          controller.pageController.error.toString(),
                          () => controller.pageController.refresh(),
                        );
                      },
                      newPageErrorIndicatorBuilder: (context) {
                        return CustomErrorWidget(
                          controller.pageController.error.toString(),
                          () => controller.pageController
                              .retryLastFailedRequest(),
                        );
                      },
                      noItemsFoundIndicatorBuilder: (context) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32, horizontal: 16),
                            child: Column(
                              children: [
                                Text(
                                  'Ничего не найдено',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Text(
                                  'Попробуй поискать что-то другое',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// class SearchTypeWidget extends ConsumerWidget {
//   const SearchTypeWidget({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(searchTypeProvider);
//     return PopupMenuButton<SearchState>(
//       tooltip: 'Выбор поиска',
//       initialValue: state,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       itemBuilder: (context) => const [
//         PopupMenuItem(
//           value: SearchState.anime,
//           child: Text('Аниме'),
//         ),
//         PopupMenuItem(
//           value: SearchState.manga,
//           child: Text('Манга'),
//         ),
//         PopupMenuItem(
//           value: SearchState.ranobe,
//           child: Text('Ранобе'),
//         ),
//       ],
//       onSelected: (value) {
//         ref.read(searchTypeProvider.notifier).state = value;
//       },
//     );
//   }
// }

class SearchTypeChips extends ConsumerWidget {
  const SearchTypeChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchTypeProvider);

    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: [
        ChoiceChip(
          selected: state == SearchState.anime,
          //labelPadding: const EdgeInsets.all(0),
          label: const Text('Аниме'),
          onSelected: (bool selected) {
            ref.read(searchTypeProvider.notifier).state = SearchState.anime;
          },
        ),
        ChoiceChip(
          selected: state == SearchState.manga,
          label: const Text('Манга'),
          onSelected: (bool selected) {
            ref.read(searchTypeProvider.notifier).state = SearchState.manga;
          },
        ),
        ChoiceChip(
          selected: state == SearchState.ranobe,
          label: const Text('Ранобе'),
          onSelected: (bool selected) {
            ref.read(searchTypeProvider.notifier).state = SearchState.ranobe;
          },
        ),
      ],
    );
  }
}

class AnimeSearchHistory extends StatelessWidget {
  final List<String> history;
  final Function(String) search;
  final VoidCallback clear;

  const AnimeSearchHistory(
      {super.key,
      required this.history,
      required this.search,
      required this.clear});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
                child: Text(
                  'История поиска',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        fontSize: 14,
                      ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: history.isEmpty ? null : () => clear(),
                child: const Text('Очистить'),
              ),
            ],
          ),
        ),
        if (history.isNotEmpty)
          SliverList.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              final e = history[index];
              return ListTile(
                onTap: () => search(e),
                leading: const Icon(Icons.history),
                title: Text(
                  e,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Text(
                'История поиска',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      fontSize: 14,
                    ),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: history.isEmpty ? null : () => clear(),
              child: const Text('Очистить'),
            ),
            // const SizedBox(
            //   width: 16,
            // ),
          ],
        ),
        if (history.isNotEmpty)
          Expanded(
            child: ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final e = history[index];
                return ListTile(
                  onTap: () => search(e),
                  leading: const Icon(Icons.history),
                  title: Text(
                    e,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class NothingFound extends StatelessWidget {
  const NothingFound({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Ничено не найдено',
          style:
              Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 16),
        ),
      ),
    );
  }
}
