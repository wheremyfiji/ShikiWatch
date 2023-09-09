enum AnimeSource {
  alwaysAsk,
  kodik,
  libria;

  String get name {
    return switch (this) {
      AnimeSource.alwaysAsk => 'Всегда спрашивать',
      AnimeSource.kodik => 'Kodik',
      AnimeSource.libria => 'AniLibria',
    };
  }
}
