import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';

enum RateStatus {
  planned('planned'),
  watching('watching'),
  rewatching('rewatching'),
  completed('completed'),
  onHold('on_hold'),
  dropped('dropped');

  final String value;

  const RateStatus(this.value);

  static RateStatus fromValue(String value) =>
      RateStatus.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      RateStatus.planned => 'В планах',
      RateStatus.watching => 'Смотрю',
      RateStatus.rewatching => 'Пересматриваю',
      RateStatus.completed => 'Просмотрено',
      RateStatus.onHold => 'Отложено',
      RateStatus.dropped => 'Брошено',
    };
  }

  Color color(ColorScheme colorScheme) {
    return switch (this) {
      RateStatus.planned =>
        Colors.lime.shade400.harmonizeWith(colorScheme.primary),
      RateStatus.completed =>
        Colors.green.shade400.harmonizeWith(colorScheme.primary),
      RateStatus.onHold =>
        Colors.blue.shade400.harmonizeWith(colorScheme.primary),
      RateStatus.dropped =>
        Colors.red.shade400.harmonizeWith(colorScheme.primary),
      _ => Colors.deepPurple.shade300.harmonizeWith(colorScheme.primary),
    };
  }
}

enum AnimeOrigin {
  original('original'),
  manga('manga'),
  webManga('web_manga'),
  fourKomaManga('four_koma_manga'),
  novel('novel'),
  webNovel('web_novel'),
  visualNovel('visual_novel'),
  lightNovel('light_novel'),
  game('game'),
  cardGame('card_game'),
  music('music'),
  radio('radio'),
  book('book'),
  pictureBook('picture_book'),
  mixedMedia('mixed_media'),
  other('other'),
  unknown('unknown');

  final String value;

  const AnimeOrigin(this.value);

  static AnimeOrigin fromValue(String value) =>
      AnimeOrigin.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      AnimeOrigin.original => 'Оригинал',
      AnimeOrigin.manga => 'Манга',
      AnimeOrigin.webManga => 'Веб-манга',
      AnimeOrigin.fourKomaManga => 'Енкома',
      AnimeOrigin.novel => 'Новелла',
      AnimeOrigin.webNovel => 'Веб-новелла',
      AnimeOrigin.visualNovel => 'Визуальная новелла',
      AnimeOrigin.lightNovel => 'Ранобэ',
      AnimeOrigin.game => 'Игра',
      AnimeOrigin.cardGame => 'Карточная игра',
      AnimeOrigin.music => 'Музыка',
      AnimeOrigin.radio => 'Радио',
      AnimeOrigin.book => 'Книга',
      AnimeOrigin.pictureBook => 'Книга с картинками',
      AnimeOrigin.mixedMedia => 'Несколько',
      AnimeOrigin.other => 'Прочее',
      AnimeOrigin.unknown => 'Неизвестен',
    };
  }
}

enum GenreKind {
  demographic('demographic'),
  genre('genre'),
  theme('theme');

  final String value;

  const GenreKind(this.value);

  static GenreKind fromValue(String value) =>
      GenreKind.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      // GenreKind.demographic => 'В планах',
      // GenreKind.genre => 'Жанр',
      GenreKind.theme => 'Тема',
      _ => 'Жанр',
    };
  }
}

enum TitleKind {
  // anime
  tv('tv'),
  movie('movie'),
  ova('ova'),
  ona('ona'),
  special('special'),
  tvSpecial('tv_special'),
  music('music'),
  pv('pv'),
  cm('cm'),
  // manga
  manga('manga'),
  manhwa('manhwa'),
  manhua('manhua'),
  lightNovel('light_novel'),
  novel('novel'),
  oneShot('one_shot'),
  doujin('doujin'),
  // bruh
  unknown('unknown');

  final String value;

  const TitleKind(this.value);

  static TitleKind fromValue(String value) =>
      TitleKind.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      TitleKind.tv => 'ТВ',
      TitleKind.movie => 'Фильм',
      TitleKind.ova => 'OVA',
      TitleKind.ona => 'ONA',
      TitleKind.special => 'Спешл',
      TitleKind.tvSpecial => 'ТВ спешл',
      TitleKind.music => 'Клип',
      TitleKind.pv => 'Промо',
      TitleKind.cm => 'Реклама',
      TitleKind.manga => 'Манга',
      TitleKind.manhwa => 'Манхва',
      TitleKind.manhua => 'Маньхуа',
      TitleKind.lightNovel => 'Ранобе',
      TitleKind.novel => 'Новелла',
      TitleKind.oneShot => 'Ваншот',
      TitleKind.doujin => 'Додзинси',
      TitleKind.unknown => 'unknown',
    };
  }
}

enum AnimeRating {
  none('none'),
  g('g'),
  pg('pg'),
  pg13('pg_13'),
  r('r'),
  rPlus('r_plus'),
  rx('rx');

  final String value;

  const AnimeRating(this.value);

  String get name {
    return switch (this) {
      AnimeRating.none => '',
      AnimeRating.g => 'G',
      AnimeRating.pg => 'PG',
      AnimeRating.pg13 => 'PG-13',
      AnimeRating.r => 'R-17',
      AnimeRating.rPlus => 'R+',
      AnimeRating.rx => 'Rx',
    };
  }

  static AnimeRating fromValue(String value) =>
      AnimeRating.values.singleWhere((e) => value == e.value);
}

enum AnimeStatus {
  unknown('unknown'),
  anons('anons'),
  ongoing('ongoing'),
  released('released');

  final String value;

  const AnimeStatus(this.value);

  static AnimeStatus fromValue(String value) =>
      AnimeStatus.values.singleWhere((e) => value == e.value);

  String get rusName {
    return switch (this) {
      AnimeStatus.anons => 'Анонс',
      AnimeStatus.ongoing => 'Онгоинг',
      AnimeStatus.released => 'Вышло',
      AnimeStatus.unknown => '',
    };
  }
}
