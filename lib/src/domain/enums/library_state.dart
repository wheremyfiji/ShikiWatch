enum LibraryFragmentMode {
  anime,
  manga;

  String get name {
    return switch (this) {
      LibraryFragmentMode.anime => 'Аниме',
      LibraryFragmentMode.manga => 'Манга и ранобе',
    };
  }
}
