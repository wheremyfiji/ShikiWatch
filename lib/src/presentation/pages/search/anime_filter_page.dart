import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../domain/models/genre.dart';
import '../../../domain/models/studio.dart';
import '../../providers/anime_search_provider.dart';

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    Key? key,
    required this.title,
    required this.onClearAll,
    required this.options,
    this.canClear = false,
  }) : super(key: key);

  final String title;
  final Widget options;
  final Function()? onClearAll;
  final bool canClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
          isThreeLine: false,
          trailing: canClear
              ? IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onClearAll ?? () {},
                  icon: const Icon(Icons.clear_all_outlined),
                )
              : const SizedBox.shrink(),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: options,
        )
      ],
    );
  }
}

class AnimeFilterPage extends ConsumerWidget {
  const AnimeFilterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(animeSearchProvider);
    return Scaffold(
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     context.pop();
      //     ref.read(animeSearchProvider).applyFilter();
      //   },
      //   label: const Text('Применить'),
      //   icon: const Icon(Icons.done_all),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Фильтры'),
            // actions: [
            //   IconButton(
            //     onPressed: () => ref.read(animeSearchProvider).clearFilter(),
            //     tooltip: "Сбросить",
            //     icon: const Icon(Icons.refresh), //restart_alt_outlined  refresh
            //   ),
            // ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  'Жанр',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                title: (c.selectedGenres?.isEmpty ?? true)
                    ? null
                    : Text(
                        c.selectedGenres!.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                trailing: Tooltip(
                  message: 'Выбрать жанры',
                  child: IconButton(
                    onPressed: () {
                      showFlexibleBottomSheet(
                        decoration: BoxDecoration(
                          color: context.theme.colorScheme.background,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                        ),
                        //bottomSheetColor: context.theme.colorScheme.background,
                        bottomSheetColor: Colors.transparent,
                        minHeight: 0,
                        initHeight: 0.5,
                        maxHeight: 1,
                        context: context,
                        anchors: [0, 0.5, 1],
                        isSafeArea: true,
                        duration: const Duration(milliseconds: 250),
                        builder:
                            (context, scrollController, bottomSheetOffset) {
                          return GenresBottomSheet(
                            scrollController: scrollController,
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
              ),
            ),
          ),

          // SliverPadding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          //   sliver: SliverToBoxAdapter(
          //     child: ListTile(
          //       contentPadding: EdgeInsets.zero,
          //       leading: Text(
          //         'Студия',
          //         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          //               fontSize: 16,
          //               fontWeight: FontWeight.w500,
          //             ),
          //       ),
          //       title: Text(
          //         '8 bit',
          //         maxLines: 2,
          //         overflow: TextOverflow.ellipsis,
          //         style: Theme.of(context).textTheme.bodySmall,
          //       ),
          //       trailing: IconButton(
          //         onPressed: () {
          //           showFlexibleBottomSheet(
          //             decoration: BoxDecoration(
          //               color: context.theme.colorScheme.background,
          //               borderRadius: const BorderRadius.only(
          //                 topLeft: Radius.circular(16.0),
          //                 topRight: Radius.circular(16.0),
          //               ),
          //             ),
          //             //bottomSheetColor: context.theme.colorScheme.background,
          //             bottomSheetColor: Colors.transparent,
          //             minHeight: 0,
          //             initHeight: 0.5,
          //             maxHeight: 1,
          //             context: context,
          //             anchors: [0, 0.5, 1],
          //             isSafeArea: true,
          //             duration: const Duration(milliseconds: 250),
          //             builder: (context, scrollController, bottomSheetOffset) {
          //               return StudiosBottomSheet(
          //                 scrollController: scrollController,
          //               );
          //             },
          //           );
          //         },
          //         icon: const Icon(Icons.add),
          //       ),
          //     ),
          //   ),
          // ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Тип',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...List.generate(
                        animeKindList.length,
                        (index) {
                          final kind = animeKindList[index];
                          return CustomFilterChip(
                            label: kind.russian,
                            selected: c.isKindSelected(kind),
                            onSelected: (b) => ref
                                .read(animeSearchProvider)
                                .toggleKind(k: kind, t: b),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Статус',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
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
                              ref
                                  .read(animeSearchProvider)
                                  .toggleStatus(s: s, t: b);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Длительность эпизода',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
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
                            onSelected: (b) => ref
                                .read(animeSearchProvider)
                                .toggleEpDuration(e: e, t: b),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // SliverPadding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          //   sliver: SliverToBoxAdapter(
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Возрастное ограничение',
          //           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //         ),
          //         const SizedBox(
          //           height: 8,
          //         ),
          //         Wrap(
          //           spacing: 8,
          //           children: const [
          //             CustomFilterChip(
          //               label: 'G',
          //               selected: false,
          //             ),
          //             CustomFilterChip(
          //               label: 'PG',
          //               selected: false,
          //             ),
          //             CustomFilterChip(
          //               label: 'PG13',
          //               selected: true,
          //             ),
          //             CustomFilterChip(
          //               label: 'R',
          //               selected: false,
          //             ),
          //             CustomFilterChip(
          //               label: 'R+',
          //               selected: false,
          //             ),
          //             CustomFilterChip(
          //               label: 'Rx',
          //               selected: false,
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'В моём списке',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...List.generate(
                        animeMyList.length,
                        (index) {
                          final l = animeMyList[index];
                          return CustomFilterChip(
                            label: l.russian,
                            selected: c.isMyListSelected(l),
                            onSelected: (b) => ref
                                .read(animeSearchProvider)
                                .toggleMyList(l: l, t: b),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сортировать по',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...List.generate(
                        animeSortList.length,
                        (index) {
                          final sort = animeSortList[index];
                          return CustomFilterChip(
                            label: sort.russian,
                            selected: c.isSortTypeSelected(sort),
                            onSelected: (b) => ref
                                .read(animeSearchProvider)
                                .toggleSortType(sort: sort, t: b),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          //const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: context.theme.colorScheme.background,
        elevation: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                //context.pop();
                ref.read(animeSearchProvider).clearFilter();
              },
              icon: const Icon(Icons.refresh), //restart_alt_outlined  refresh
              label: const Text('Сбросить'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.pop();
                ref.read(animeSearchProvider).applyFilter();
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Применить'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Function(bool)? onSelected;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.selected,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      padding: const EdgeInsets.all(6), //0
      shadowColor: Colors.transparent,
      elevation: 0,
      // side: const BorderSide(width: 0, color: Colors.transparent),
      // labelStyle: context.theme.textTheme.bodyMedium
      //     ?.copyWith(color: context.theme.colorScheme.onSecondaryContainer),
      // backgroundColor: context.theme.colorScheme.secondaryContainer,
      label: Text(label),
      selected: selected,
      onSelected: (value) =>
          onSelected == null ? print('onSelected == null') : onSelected!(value),
    );
  }
}

final studiosListProvider = FutureProvider<List<Studio>>((ref) async {
  String data =
      await rootBundle.loadString('assets/shiki-studios-filtered-sorted.json');

  final jsonResult = json.decode(data);

  return [for (final e in jsonResult) Studio.fromJson(e)];
});

class StudiosBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const StudiosBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(animeSearchProvider);
    final studiosList = ref.watch(studiosListProvider);

    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Студии',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  const Tooltip(
                    message: 'Очистить всё',
                    child: IconButton(
                      onPressed: null,
                      // (c.selectedGenres?.isEmpty ?? true)
                      //     ? null
                      //     : () {
                      //         ref
                      //             .read(animeSearchProvider)
                      //             .clearSelectedGenres();
                      //       },
                      icon: Icon(Icons.clear_all),
                    ),
                  ),
                ],
              ),
              ...[
                studiosList.when(
                  error: (error, stackTrace) {
                    return const Center(child: Text('data'));
                  },
                  loading: () {
                    return const Center(child: CircularProgressIndicator());
                  },
                  data: (data) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shadowColor: Colors.transparent,
                      margin: EdgeInsets.zero,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        physics: const ClampingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final studio = data[index];

                          const isSelected = false;

                          // final isSelected =
                          //     c.selectedGenres?.contains(genre) ?? false;

                          return ListTile(
                            //selected: isSelected,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              studio.filteredName!,
                            ),
                            trailing: isSelected
                                ? IconButton(
                                    onPressed: () {
                                      // ref
                                      //     .read(animeSearchProvider)
                                      //     .removeGenre(genre);
                                    },
                                    icon: const Icon(Icons.remove_circle),
                                  )
                                : IconButton(
                                    onPressed: () {
                                      // ref
                                      //     .read(animeSearchProvider)
                                      //     .addGenre(genre);
                                    },
                                    icon: const Icon(Icons.add_circle),
                                  ),
                            //onTap: () => Navigator.pop(context),
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class GenresBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const GenresBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(animeSearchProvider);
    return Material(
      color: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Жанры',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Очистить всё',
                    child: IconButton(
                      onPressed: (c.selectedGenres?.isEmpty ?? true)
                          ? null
                          : () {
                              ref
                                  .read(animeSearchProvider)
                                  .clearSelectedGenres();
                            },
                      icon: const Icon(Icons.clear_all),
                    ),
                  ),
                ],
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                shadowColor: Colors.transparent,
                margin: EdgeInsets.zero,
                child: ListView.builder(
                  //padding: EdgeInsets.zero,
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: animeGenres.length,
                  itemBuilder: (context, index) {
                    final genre = animeGenres[index];
                    // ребилдит весь список, что плохо
                    final isSelected =
                        c.selectedGenres?.contains(genre) ?? false;
                    return ListTile(
                      selected: isSelected,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        genre.russian!,
                      ),
                      trailing: isSelected
                          ? IconButton(
                              onPressed: () {
                                ref
                                    .read(animeSearchProvider)
                                    .removeGenre(genre);
                              },
                              icon: const Icon(Icons.remove_circle),
                            )
                          : IconButton(
                              onPressed: () {
                                ref.read(animeSearchProvider).addGenre(genre);
                              },
                              icon: const Icon(Icons.add_circle),
                            ),
                      //onTap: () => Navigator.pop(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<Genre> animeGenres = [
  Genre(
    id: 5,
    russian: 'Безумие',
  ),
  Genre(
    id: 17,
    russian: 'Боевые искусства',
  ),
  Genre(
    id: 32,
    russian: 'Вампиры',
  ),
  Genre(
    id: 38,
    russian: 'Военное',
  ),
  Genre(
    id: 35,
    russian: 'Гарем',
  ),
  Genre(
    id: 543,
    russian: 'Гурман',
  ),
  Genre(
    id: 6,
    russian: 'Демоны',
  ),
  Genre(
    id: 7,
    russian: 'Детектив',
  ),
  Genre(
    id: 15,
    russian: 'Детское',
  ),
  Genre(
    id: 43,
    russian: 'Дзёсей',
  ),
  Genre(
    id: 8,
    russian: 'Драма',
  ),
  Genre(
    id: 11,
    russian: 'Игры',
  ),
  Genre(
    id: 13,
    russian: 'Исторический',
  ),
  Genre(
    id: 4,
    russian: 'Комедия',
  ),
  Genre(
    id: 29,
    russian: 'Космос',
  ),

  Genre(
    id: 16,
    russian: 'Магия',
  ),
  Genre(
    id: 3,
    russian: 'Машины',
  ),
  Genre(
    id: 18,
    russian: 'Меха',
  ),
  Genre(
    id: 19,
    russian: 'Музыка',
  ),
  Genre(
    id: 20,
    russian: 'Пародия',
  ),
  Genre(
    id: 36,
    russian: 'Повседневность',
  ),
  Genre(
    id: 39,
    russian: 'Полиция',
  ),
  Genre(
    id: 2,
    russian: 'Приключения',
  ),
  Genre(
    id: 40,
    russian: 'Психологическое',
  ),
  Genre(
    id: 541,
    russian: 'Работа',
  ),
  Genre(
    id: 22,
    russian: 'Романтика',
  ),
  Genre(
    id: 21,
    russian: 'Самураи',
  ),
  Genre(
    id: 37,
    russian: 'Сверхъестественное',
  ),
  Genre(
    id: 30,
    russian: 'Спорт',
  ),
  Genre(
    id: 31,
    russian: 'Супер сила',
  ),
  Genre(
    id: 42,
    russian: 'Сэйнэн',
  ),
  Genre(
    id: 25,
    russian: 'Сёдзё',
  ),
  Genre(
    id: 26,
    russian: 'Сёдзё-ай',
  ),
  Genre(
    id: 27,
    russian: 'Сёнен',
  ),
  Genre(
    id: 28,
    russian: 'Сёнен-ай',
  ),
  Genre(
    id: 41,
    russian: 'Триллер',
  ),
  Genre(
    id: 14,
    russian: 'Ужасы',
  ),
  Genre(
    id: 24,
    russian: 'Фантастика',
  ),
  Genre(
    id: 10,
    russian: 'Фэнтези',
  ),
  // Genre(
  //   id: 12,
  //   russian: 'Хентай',
  // ),
  Genre(
    id: 23,
    russian: 'Школа',
  ),
  Genre(
    id: 1,
    russian: 'Экшен',
  ),
  // Genre(
  //   id: 539,
  //   russian: 'Эротика',
  // ),
  // Genre(
  //   id: 9,
  //   russian: 'Этти',
  // ),
  // Genre(
  //   id: 34,
  //   russian: 'Юри',
  // ),
  // Genre(
  //   id: 33,
  //   russian: 'Яой',
  // ),
];
