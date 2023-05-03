enum LibraryState {
  anime,
  manga,
}

extension LibraryStateName on LibraryState {
  String get name {
    switch (this) {
      case LibraryState.anime:
        return 'Аниме';
      case LibraryState.manga:
        return 'Манга и ранобэ';
    }
  }
}
