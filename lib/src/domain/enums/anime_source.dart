enum AnimeSource {
  alwaysAsk,
  kodik,
  anilib,
  libria;

  String get name {
    return switch (this) {
      AnimeSource.alwaysAsk => 'Всегда спрашивать',
      AnimeSource.kodik => 'Kodik',
      AnimeSource.anilib => 'AniLib',
      AnimeSource.libria => 'AniLibria',
    };
  }
}
