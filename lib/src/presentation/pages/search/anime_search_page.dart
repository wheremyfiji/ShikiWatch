import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../domain/models/animes.dart';
import '../../../utils/shiki_utils.dart';
import '../../providers/anime_search_provider.dart';
import '../../../constants/config.dart';
import '../../../domain/models/animes.dart' as models;
import '../../widgets/error_widget.dart';
import '../../widgets/image_with_shimmer.dart';

final searchTypeProvider = StateProvider<int>((ref) {
  return 0;
});

// const List<String> searchTypeList = <String>[
//   'Аниме',
//   'Манга',
//   'Ранобэ',
// ];

const List<String> searchHintList = <String>[
  'Поиск аниме',
  'Поиск манги',
  'Поиск ранобэ',
];

class AnimeSearchPage extends ConsumerWidget {
  const AnimeSearchPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(animeSearchProvider);

    final seatchTypeState = ref.watch(searchTypeProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      onPanDown: (_) {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          //onPressed: null,
          onPressed: () => context.pushNamed('search_filters'),
          icon: const Icon(Icons.tune), //tune  filter_list  done_all
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
              //hintText: 'Поиск аниме',
              hintText: searchHintList[seatchTypeState],
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
          actions: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: SearchTypeWidget(),
            ),
          ],
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
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
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
                  padding: const EdgeInsets.all(8.0),
                  sliver: PagedSliverGrid<int, Animes>(
                    addAutomaticKeepAlives: true,
                    showNewPageErrorIndicatorAsGridChild: false,
                    //showNoMoreItemsIndicatorAsGridChild: false,
                    pagingController: controller.pageController,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      mainAxisExtent: 220,
                    ),
                    builderDelegate: PagedChildBuilderDelegate<Animes>(
                      itemBuilder: (context, item, index) {
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: SearchTile(item),
                        );
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
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SearchTypeWidget extends ConsumerWidget {
  const SearchTypeWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchTypeProvider);
    return PopupMenuButton<int>(
      tooltip: 'Выбор поиска',
      initialValue: state,
      // child: Card(
      //   child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: Text(
      //       searchTypeList[state],
      //     ),
      //   ),
      // ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 0,
          child: Text('Аниме'),
        ),
        PopupMenuItem(
          value: 1,
          child: Text('Манга'),
        ),
        PopupMenuItem(
          value: 2,
          child: Text('Ранобэ'),
        ),
      ],
      onSelected: (value) {
        ref.read(searchTypeProvider.notifier).state = value;
      },
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            const SizedBox(
              width: 16,
            ),
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

class SearchTile extends StatelessWidget {
  //final Animes data;
  final models.Animes data;

  const SearchTile(
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.transparent,
      //margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: InkWell(
        onTap: () => context.push('/explore/${data.id!}', extra: data),
        child: Column(
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //Hero(
            //  tag: data.id!,
            //  child:
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ImageWithShimmerWidget(
                imageUrl: AppConfig.staticUrl + (data.image?.original ?? ''),
                width: 120,
                height: 150,
              ),
            ),
            //),
            const SizedBox(
              height: 4,
            ),
            Padding(
              // padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              padding: const EdgeInsets.all(0),
              child: Text(
                data.russian ?? data.name ?? '',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${getKind(data.kind ?? '')} • ${data.score}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
                const Icon(
                  Icons.star,
                  size: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
