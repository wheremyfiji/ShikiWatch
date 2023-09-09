enum SearchType {
  anime,
  manga,
  ranobe;
  //character,

  String get searchHintText {
    return switch (this) {
      SearchType.anime => 'Поиск аниме',
      SearchType.manga => 'Поиск манги',
      SearchType.ranobe => 'Поиск ранобе',
      //SearchType.character => 'Поиск персонажа',
    };
  }
}
