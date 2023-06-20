enum LibraryFragmentMode {
  anime,
  manga,
}

extension LibraryFragmentModeName on LibraryFragmentMode {
  String get name {
    switch (this) {
      case LibraryFragmentMode.anime:
        return 'Аниме';
      case LibraryFragmentMode.manga:
        return 'Манга и ранобе';
    }
  }
}
