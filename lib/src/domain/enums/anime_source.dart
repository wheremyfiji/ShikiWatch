enum AnimeSource {
  alwaysAsk,
  kodik,
  anilib,
  liberty,
  anime365;

  String get name {
    return switch (this) {
      AnimeSource.alwaysAsk => 'Всегда спрашивать',
      AnimeSource.kodik => 'Kodik',
      AnimeSource.anilib => 'AniLib',
      AnimeSource.liberty => 'AniLiberty',
      AnimeSource.anime365 => 'Anime365',
    };
  }
}
