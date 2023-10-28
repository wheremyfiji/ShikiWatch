enum LibraryLayoutMode {
  compactList,
  list,
  grid;

  String get name {
    return switch (this) {
      LibraryLayoutMode.compactList => 'Компактный список',
      LibraryLayoutMode.list => 'Список',
      LibraryLayoutMode.grid => 'Сетка',
    };
  }
}
