import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../domain/enums/search_state.dart';
import '../../../providers/anime_search_provider.dart';

class SearchTypeChips extends ConsumerWidget {
  final SearchPageParameters t;

  const SearchTypeChips(this.t, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchType = ref.watch(animeSearchProvider(t)).searchType;

    return Wrap(
      spacing: 8,
      runSpacing: 0,
      children: [
        ChoiceChip(
          selected: searchType == SearchType.anime,
          //labelPadding: const EdgeInsets.all(0),
          label: const Text('Аниме'),
          onSelected: (bool selected) {
            ref.read(animeSearchProvider(t)).changeSearchType(SearchType.anime);
          },
        ),
        ChoiceChip(
          selected: searchType == SearchType.manga,
          label: const Text('Манга'),
          onSelected: (bool selected) {
            ref.read(animeSearchProvider(t)).changeSearchType(SearchType.manga);
          },
        ),
        ChoiceChip(
          selected: searchType == SearchType.ranobe,
          label: const Text('Ранобе'),
          onSelected: (bool selected) {
            ref
                .read(animeSearchProvider(t))
                .changeSearchType(SearchType.ranobe);
          },
        ),
      ],
    );
  }
}
