enum SearchState {
  anime,
  manga,
  ranobe,
  character,
}

extension SearchStateEx on SearchState {
  String get searchHintText {
    switch (this) {
      case SearchState.anime:
        return 'Поиск аниме';
      case SearchState.manga:
        return 'Поиск манги';
      case SearchState.ranobe:
        return 'Поиск ранобе';
      case SearchState.character:
        return 'Поиск персонажа';
    }
  }
}
