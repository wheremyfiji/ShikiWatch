import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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
                  icon: const Icon(Icons.clear_all_outlined))
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pop();
          ref.read(animeSearchProvider).applyFilter();
        },
        label: const Text('Применить'),
        icon: const Icon(Icons.done_all),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Фильтры'),
            actions: [
              IconButton(
                onPressed: () => ref.read(animeSearchProvider).clearFilter(),
                tooltip: "Сбросить",
                icon: const Icon(Icons.refresh), //restart_alt_outlined  refresh
              ),
            ],
          ),

          // SliverPadding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          //   sliver: SliverToBoxAdapter(
          //     child: Container(
          //       color: Colors.red,
          //       height: 60,
          //     ),
          //   ),
          // ),
          // SliverPadding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          //   sliver: SliverToBoxAdapter(
          //     child: MultipleSearchSelection<Genre>(
          //       caseSensitiveSearch: false,
          //       fuzzySearch: FuzzySearch.none,
          //       itemsVisibility: ShowedItemsVisibility.onType,
          //       maximumShowItemsHeight: 200,
          //       searchFieldBoxDecoration:
          //           const BoxDecoration(color: Colors.transparent),
          //       hintText: 'Начни писать для поиска',
          //       title: Padding(
          //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
          //         child: Text(
          //           'Жанры',
          //           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
          //                 fontSize: 16,
          //                 fontWeight: FontWeight.w500,
          //               ),
          //         ),
          //       ),
          //       onItemAdded: (c) {
          //         print('onItemAdded: ${c.id}');
          //       },
          //       showClearSearchFieldButton: true,
          //       items: animeGenres,
          //       fieldToCheck: (c) {
          //         return c.russian;
          //       },
          //       itemBuilder: (genre, index) {
          //         return Card(
          //           margin: const EdgeInsets.all(4.0),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //               vertical: 16.0,
          //               horizontal: 8.0,
          //             ),
          //             child: Text(genre.russian),
          //           ),
          //         );

          //         return Padding(
          //           padding: const EdgeInsets.all(0.0),
          //           child: Padding(
          //             padding: const EdgeInsets.symmetric(
          //               vertical: 16.0,
          //               horizontal: 8.0,
          //             ),
          //             child: Text(genre.russian),
          //           ),
          //         );
          //       },
          //       // itemBuilder: (country, index) {
          //       //   return Padding(
          //       //     padding: const EdgeInsets.all(6.0),
          //       //     child: Container(
          //       //       decoration: BoxDecoration(
          //       //         borderRadius: BorderRadius.circular(6),
          //       //         color: Colors.white,
          //       //       ),
          //       //       child: Padding(
          //       //         padding: const EdgeInsets.symmetric(
          //       //           vertical: 20.0,
          //       //           horizontal: 12,
          //       //         ),
          //       //         child: Text(country.name),
          //       //       ),
          //       //     ),
          //       //   );
          //       // },
          //       pickedItemBuilder: (genre) {
          //         return Chip(
          //           padding: const EdgeInsets.all(0),
          //           shadowColor: Colors.transparent,
          //           elevation: 0,
          //           side: const BorderSide(width: 0, color: Colors.transparent),
          //           labelStyle: context.theme.textTheme.bodyMedium?.copyWith(
          //               color: context.theme.colorScheme.onSecondaryContainer),
          //           backgroundColor:
          //               context.theme.colorScheme.secondaryContainer,
          //           label: Text(genre.russian),
          //         );
          //         return Padding(
          //           padding: const EdgeInsets.all(8),
          //           child: Text(genre.russian),
          //         );
          //       },
          //       sortShowedItems: true,
          //       sortPickedItems: true,
          //       showSelectAllButton: false,
          //       // selectAllButton: ElevatedButton(
          //       //   onPressed: () {},
          //       //   child: const Text(
          //       //     'Выбрать всё',
          //       //   ),
          //       // ),
          //       showClearAllButton: true,
          //       clearAllButton: ElevatedButton(
          //         onPressed: () {},
          //         child: const Text(
          //           'Очистить',
          //         ),
          //       ),
          //       // selectAllButton: Padding(
          //       //   padding: const EdgeInsets.all(12.0),
          //       //   child: DecoratedBox(
          //       //     decoration: BoxDecoration(
          //       //       border: Border.all(color: Colors.blue),
          //       //     ),
          //       //     child: const Padding(
          //       //       padding: EdgeInsets.all(8.0),
          //       //       child: Text(
          //       //         'Выбрать всё',
          //       //         //style: kStyleDefault,
          //       //       ),
          //       //     ),
          //       //   ),
          //       // ),
          //       // onTapClearAll: () {
          //       //   print('object');
          //       // },
          //       noResultsWidget: const Padding(
          //         padding: EdgeInsets.all(4.0),
          //         child: Text('Ничего не найдено'),
          //       ),
          //       // Padding(
          //       //   padding: const EdgeInsets.all(12.0),
          //       //   child: DecoratedBox(
          //       //     decoration: BoxDecoration(
          //       //       border: Border.all(color: Colors.red),
          //       //     ),
          //       //     child: const Padding(
          //       //       padding: EdgeInsets.all(8.0),
          //       //       child: Text(
          //       //         'Очистить',
          //       //         //style: kStyleDefault,
          //       //       ),
          //       //     ),
          //       //   ),
          //       // ),
          //     ), // This tr
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
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
      // bottomNavigationBar: BottomAppBar(
      //   color: context.theme.colorScheme.background,
      //   elevation: 0,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     children: [
      //       ElevatedButton.icon(
      //         onPressed: () {
      //           //context.pop();
      //           ref.read(animeSearchProvider).clearFilter();
      //         },
      //         icon: const Icon(Icons.refresh), //restart_alt_outlined  refresh
      //         label: const Text('Сбросить'),
      //       ),
      //       ElevatedButton.icon(
      //         onPressed: () {
      //           context.pop();
      //           ref.read(animeSearchProvider).applyFilter();
      //         },
      //         icon: const Icon(Icons.done_all),
      //         label: const Text('Применить'),
      //       ),
      //     ],
      //   ),
      // ),
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

// TextStyle kStyleDefault = const TextStyle(
//   color: Colors.black,
//   fontSize: 16,
//   fontWeight: FontWeight.bold,
// );

List<String> animeGenreRussianNames = [
  'Безумие',
  'Боевые искусства',
  'Вампиры',
  'Военное',
  'Гарем',
  'Гурман',
  'Демоны',
  'Детектив',
  'Детское',
  'Дзёсей',
  'Драма',
  'Игры',
  'Исторический',
  'Комедия',
  'Космос',
  'Магия',
  'Машины',
  'Меха',
  'Музыка',
  'Пародия',
  'Повседневность',
  'Полиция',
  'Приключения',
  'Психологическое',
  'Работа',
  'Романтика',
  'Самураи',
  'Сверхъестественное',
  'Спорт',
  'Супер сила',
  'Сэйнэн',
  'Сёдзё',
  'Сёдзё-ай',
  'Сёнен',
  'Сёнен-ай',
  'Триллер',
  'Ужасы',
  'Фантастика',
  'Фэнтези',
  'Хентай?',
  'Школа',
  'Экшен',
  'Эротика?',
  'Этти',
  'Юри',
  'Яой', // для милых дам
];

List<Genre> animeGenres = List<Genre>.generate(
  animeGenreRussianNames.length,
  (index) => Genre(
    id: index,
    kind: 'anime',
    name: '',
    russian: animeGenreRussianNames[index],
  ),
);

class Genre {
  final int id;
  final String kind;
  final String name;
  final String russian;

  const Genre(
      {required this.id,
      required this.kind,
      required this.name,
      required this.russian});
}
