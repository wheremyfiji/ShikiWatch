enum AnimeSource {
  alwaysAsk,
  kodik,
  anilib,
  libria,
  anime365;

  String get name {
    return switch (this) {
      AnimeSource.alwaysAsk => 'Всегда спрашивать',
      AnimeSource.kodik => 'Kodik',
      AnimeSource.anilib => 'AniLib',
      AnimeSource.libria => 'AniLibria',
      AnimeSource.anime365 => 'Anime365',
    };
  }
}
