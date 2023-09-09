enum LibraryLayoutMode {
  list,
  grid;

  String get name {
    return switch (this) {
      LibraryLayoutMode.list => 'Список',
      LibraryLayoutMode.grid => 'Сетка',
    };
  }
}
