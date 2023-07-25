enum AnimeSource {
  alwaysAsk,
  kodik,
  libria,
}

extension AnimeSourceExt on AnimeSource {
  String get name {
    switch (this) {
      case AnimeSource.alwaysAsk:
        return 'Всегда спрашивать';
      case AnimeSource.kodik:
        return 'Kodik';
      case AnimeSource.libria:
        return 'AniLibria';
    }
  }
}
