enum SearchType {
  anime,
  manga,
  ranobe,
  //character,
}

extension SearchTypeExtension on SearchType {
  String get searchHintText {
    switch (this) {
      case SearchType.anime:
        return 'Поиск аниме';
      case SearchType.manga:
        return 'Поиск манги';
      case SearchType.ranobe:
        return 'Поиск ранобе';
      //case SearchType.character:
      //  return 'Поиск персонажа';
    }
  }
}
