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
        const SizedBox(
          width: 8.0,
        ),
        ChoiceChip(
          label: const Text('Аниме'),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          selected: searchType == SearchType.anime,
          onSelected: (_) => ref
              .read(animeSearchProvider(t))
              .changeSearchType(SearchType.anime),
        ),
        ChoiceChip(
          label: const Text('Манга'),
          selected: searchType == SearchType.manga,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          onSelected: (_) => ref
              .read(animeSearchProvider(t))
              .changeSearchType(SearchType.manga),
        ),
        ChoiceChip(
          label: const Text('Ранобе'),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          selected: searchType == SearchType.ranobe,
          onSelected: (_) => ref
              .read(animeSearchProvider(t))
              .changeSearchType(SearchType.ranobe),
        ),
        const SizedBox(
          width: 8.0,
        ),
      ],
    );
  }
}
