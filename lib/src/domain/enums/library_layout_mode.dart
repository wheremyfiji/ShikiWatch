enum LibraryLayoutMode {
  list,
  grid,
}

extension LibraryLayoutModeName on LibraryLayoutMode {
  String get name {
    switch (this) {
      case LibraryLayoutMode.list:
        return 'Список';
      case LibraryLayoutMode.grid:
        return 'Сетка';
    }
  }
}
