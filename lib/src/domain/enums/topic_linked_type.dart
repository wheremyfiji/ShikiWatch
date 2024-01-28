enum LinkedType {
  anime('Anime'),
  manga('Manga'),
  ranobe('Ranobe'),
  character('Character'),
  person('Person'),
  club('Club'),
  clubPage('ClubPage'),
  critique('Critique'),
  review('Review'),
  contest('Contest'),
  cosplayGallery('CosplayGallery'),
  collection('Collection'),
  article('Article'),

  unknown('unknown');

  final String value;

  const LinkedType(this.value);

  static LinkedType fromValue(String? value) => LinkedType.values.singleWhere(
        (e) => value == e.value,
        orElse: () => LinkedType.unknown,
      );

  String get rusName {
    return switch (this) {
      LinkedType.anime => 'Аниме',
      LinkedType.manga => 'Манга',
      LinkedType.ranobe => 'Ранобе',
      LinkedType.character => 'Персонаж',
      LinkedType.person => 'Персона',
      LinkedType.club => 'Клуб',
      LinkedType.clubPage => 'Клубная страница',
      LinkedType.critique => 'Критика',
      LinkedType.review => 'Обзор',
      LinkedType.contest => 'Контест',
      LinkedType.cosplayGallery => 'Косплей',
      LinkedType.collection => 'Коллеция',
      LinkedType.article => 'Статья',
      LinkedType.unknown => 'unknown',
    };
  }
}
