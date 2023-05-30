import 'dart:convert';

import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:shikidev/src/utils/extensions/buildcontext.dart';

import '../../../domain/models/studio.dart';
import '../../providers/anime_search_provider.dart';
import 'anime_genres.dart';

class AnimeFilterPage extends ConsumerWidget {
  final SearchPageParameters t;
  const AnimeFilterPage(this.t, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(animeSearchProvider(t));
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(
            title: Text('Фильтры'),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverToBoxAdapter(
              child: ListTile(
                horizontalTitleGap: 8, //def = 16?
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
                        //textAlign: TextAlign.start,
                      ),
                trailing: IconButton(
                  tooltip: 'Выбрать жанры',
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
                      builder: (context, scrollController, bottomSheetOffset) {
                        return GenresBottomSheet(
                          t,
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

          // SliverPadding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          //   sliver: SliverToBoxAdapter(
          //     child: FilterChipWidget(
          //       canClear: true,
          //       onClear: () => c.cleanKind(),
          //       title: 'Тип',
          //       chips: Wrap(
          //         spacing: 8,
          //         children: [
          //           ...List.generate(
          //             animeKindList.length,
          //             (index) {
          //               final kind = animeKindList[index];
          //               return CustomFilterChip(
          //                 label: kind.russian,
          //                 selected: c.isKindSelected(kind),
          //                 onSelected: (b) => ref
          //                     .read(animeSearchProvider)
          //                     .toggleKind(k: kind, t: b),
          //               );
          //             },
          //           ),
          //         ],
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
                  // const SizedBox(
                  //   height: 8,
                  // ),
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
                  // const SizedBox(
                  //   height: 4,
                  // ),
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
                  // const SizedBox(
                  //   height: 8,
                  // ),
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
                            onSelected: (b) => c.toggleMyList(l: l, t: b),
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
                            onSelected: (b) =>
                                c.toggleSortType(sort: sort, t: b),
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
            OutlinedButton.icon(
              onPressed: () {
                //context.pop();
                c.clearFilter();
              },
              icon: const Icon(Icons.refresh), //restart_alt_outlined  refresh
              label: const Text('Сбросить'),
            ),
            FilledButton.icon(
              onPressed: () {
                c.applyFilter();
                context.pop();
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

class GenresBottomSheet extends ConsumerWidget {
  final SearchPageParameters t;
  final ScrollController scrollController;

  const GenresBottomSheet(this.t, {super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(animeSearchProvider(t));
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
                              c.clearSelectedGenres();
                            },
                      icon: const Icon(Icons.clear_all),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemBuilder: (context, index) {
                  final genre = animeGenres[index];
                  final isSelected = c.selectedGenres?.contains(genre) ?? false;
                  return CheckboxListTile(
                    contentPadding: const EdgeInsets.all(0),
                    value: isSelected,
                    onChanged: (value) {
                      if (value!) {
                        c.addGenre(genre);
                      } else {
                        c.removeGenre(genre);
                      }
                    },
                    title: Text(
                      genre.russian!,
                    ),
                  );
                },
                // separatorBuilder: (context, index) {
                //   return const SizedBox(
                //     height: 4,
                //   );
                // },
                itemCount: animeGenres.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ClipRRect(
//   borderRadius: BorderRadius.circular(50),
//   child: Material(
//     child: InkWell(
//       child: const Padding(
//         padding: EdgeInsets.all(4),
//         child: Icon(
//           Icons.clear_all_outlined,
//         ),
//       ),
//       onTap: () {},
//     ),
//   ),
// ),

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

class FilterChipWidget extends StatelessWidget {
  const FilterChipWidget({
    Key? key,
    required this.title,
    required this.chips,
    this.onClear,
    this.canClear = false,
  }) : super(key: key);

  final String title;
  final Widget chips;
  final Function()? onClear;
  final bool canClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (canClear)
              // IconButton(
              //   //padding: const EdgeInsets.all(0),
              //   tooltip: 'Очистить',
              //   onPressed: onClear,
              //   icon: const Icon(Icons.clear_all_outlined),
              // ),
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear_all_outlined),
              ),
          ],
        ),
        // if (!canClear)
        //   const SizedBox(
        //     height: 8,
        //   ),
        chips,
      ],
    );

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
              ? const IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: null,
                  icon: Icon(Icons.clear_all_outlined),
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: chips,
        )
      ],
    );
  }
}

final studiosListProvider = FutureProvider<List<Studio>>((ref) async {
  String data = '';
  //await rootBundle.loadString('assets/shiki-studios-filtered-sorted.json');

  final jsonResult = json.decode(data);

  return [for (final e in jsonResult) Studio.fromJson(e)];
});

class StudiosBottomSheet extends ConsumerWidget {
  final ScrollController scrollController;

  const StudiosBottomSheet({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final c = ref.watch(animeSearchProvider);
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
