import 'package:flutter/material.dart';

import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/shiki_title.dart';
import '../../../utils/extensions/buildcontext.dart';
import '../../widgets/manga_card.dart';
import '../../../utils/shiki_utils.dart';
import '../../../domain/enums/search_state.dart';
import '../../providers/anime_search_provider.dart';
import '../../widgets/anime_card.dart';
import '../../widgets/error_widget.dart';

import 'components/custom_filter_chip.dart';
import 'components/search_history.dart';
import 'components/search_type_chips.dart';

class AnimeSearchPage extends ConsumerWidget {
  final int? studioId;
  final int? genreId;

  const AnimeSearchPage({super.key, this.studioId, this.genreId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t =
        SearchPageParameters(studioId: studioId ?? 0, genreId: genreId ?? 0);
    final controller = ref.watch(animeSearchProvider(t));
    final currentSearchType = controller.searchType;

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
          heroTag: null,
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: TextField(
            controller: controller.textEditingController,
            focusNode: controller.focusNode,
            onChanged: controller.onSearchChanged,
            onSubmitted: (value) {
              controller.onSearchSubmitted(value);
            },
            decoration: InputDecoration(
              filled: false,
              border: InputBorder.none,
              hintText: currentSearchType.searchHintText,
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
            titleSpacing: 0.0,
            title: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SearchTypeChips(t),
            ),
          ),
        ),
        body: SafeArea(
          child: Builder(
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
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Divider(
                        height: 1,
                      ),
                    ),
                  ),
                  if (controller.filterCount.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'Кол-во фильтров: ${controller.filterCount.length}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    sliver: PagedSliverGrid<int, ShikiTitle>(
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
                      builderDelegate: PagedChildBuilderDelegate<ShikiTitle>(
                        itemBuilder: (context, item, index) {
                          if (kindIsManga(item.kind!)) {
                            final t = item.toMangaShort;
                            return MangaCardEx(t);
                          }
                          final t = item.toAnimes;
                          return AnimeTileExp(t);
                        },

                        /// надо убрать топ паддинг
                        // firstPageProgressIndicatorBuilder: (context) {
                        //   return Container(
                        //     alignment: Alignment.topCenter,
                        //     child: const LinearProgressIndicator(),
                        //   );
                        // },
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
                        noItemsFoundIndicatorBuilder: (context) =>
                            const _NothingFound(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 70)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NothingFound extends StatelessWidget {
  const _NothingFound();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '(˘･_･˘)',
          textAlign: TextAlign.center,
          style: context.textTheme.displaySmall,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 2.0),
          child: Text(
            'Ничего не найдено',
            style: context.textTheme.titleLarge,
          ),
        ),
        Text(
          'Попробуй поискать что-то другое',
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onBackground.withOpacity(
              0.8,
            ),
          ),
        ),
      ],
    );
  }
}

class FiltersBottomSheet extends ConsumerWidget {
  final SearchPageParameters extra;

  const FiltersBottomSheet(this.extra, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(animeSearchProvider(extra));

    return DraggableScrollableSheet(
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return SafeArea(
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 16, 8),
                  child: Text(
                    'Фильтр поиска',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Тип',
                    style: context.textTheme.bodyLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ...List.generate(
                      animeStatusList.length,
                      (index) {
                        final kind = animeKindList[index];
                        return CustomFilterChip(
                          label: kind.russian,
                          selected: c.isKindSelected(kind),
                          onSelected: (b) => c.toggleKind(k: kind, t: b),
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Статус',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ...List.generate(
                      animeStatusList.length,
                      (index) {
                        final s = animeStatusList[index];
                        return CustomFilterChip(
                          label: s.russian,
                          selected: c.isStatusSelected(s),
                          onSelected: (b) {
                            c.toggleStatus(s: s, t: b);
                          },
                        );
                      },
                    ),
                  ],
                ),
                Text(
                  'Длительность эпизода',
                  style: context.textTheme.bodyLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ...List.generate(
                      animeEpisodeDurationList.length,
                      (index) {
                        final e = animeEpisodeDurationList[index];
                        return CustomFilterChip(
                          label: e.russian,
                          selected: c.isEpDurationSelected(e),
                          onSelected: (b) => c.toggleEpDuration(e: e, t: b),
                        );
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.refresh,
                        ), //restart_alt_outlined  refresh
                        label: const Text('Сбросить'),
                      ),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.done_all),
                        label: const Text('Применить'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static void show(
    BuildContext context, {
    required SearchPageParameters extra,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxWidth:
            MediaQuery.of(context).size.width >= 700 ? 700 : double.infinity,
      ),
      builder: (context) => FiltersBottomSheet(extra),
    );
  }
}
