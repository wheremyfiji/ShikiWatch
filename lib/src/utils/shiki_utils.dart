String getStatus(String value) {
  String status;

  const map = {
    'anons': 'Анонс',
    'ongoing': 'Онгоинг',
    'released': 'Вышло',
    'paused': 'Приостановлено',
    'discontinued': 'Прекращено'
  };

  status = map[value] ?? 'N/A';

  return status;
}

String getKind(String value) {
  String kind;

  // const map = {
  //   'tv': 'TV',
  //   'movie': 'Фильм',
  //   'ova': 'OVA',
  //   'ona': 'ONA',
  //   'special': 'Спешл',
  //   'music': 'Клип',
  //   'manga': 'Манга',
  //   'light_novel': 'Ранобе',
  //   'novel': 'Новелла',
  //   'one_shot': 'Ваншот',
  //   'doujin': 'Додзинси',
  //   'manhwa': 'Манхва', //корейский прикол
  //   'manhua': 'Маньхуа', //китайский прикол
  // };

  const map = {
    'tv': 'TV',
    'movie': 'Фильм',
    'ova': 'OVA',
    'ona': 'ONA',
    'special': 'Спешл',
    'tv_special': 'TV спешл',
    'music': 'Клип',
    'pv': 'Промо',
    'cm': 'Реклама',
    'manga': 'Манга',
    'light_novel': 'Ранобе',
    'novel': 'Новелла',
    'one_shot': 'Ваншот',
    'doujin': 'Додзинси',
    'manhwa': 'Манхва', //корейский прикол
    'manhua': 'Маньхуа', //китайский прикол
  };

  kind = map[value] ?? '?';

  return kind;
}

bool kindIsManga(String value) {
  const kind = {
    'manga',
    'light_novel',
    'novel',
    'one_shot',
    'doujin',
    'manhwa',
    'manhua',
  };

  if (kind.contains(value)) {
    return true;
  }

  return false;
}

String getRateStatus(String value) {
  String status;

  const map = {
    'planned': 'В планах',
    'watching': 'Смотрю',
    'rewatching': 'Пересматриваю',
    'completed': 'Просмотрено',
    'on_hold': 'Отложено',
    'dropped': 'Брошено'
  };

  status = map[value] ?? 'N/A';

  return status;
}

String getSeason(int month) {
  if ([3, 4, 5].contains(month)) {
    return 'Весна';
  } else if ([6, 7, 8].contains(month)) {
    return 'Лето';
  } else if ([9, 10, 11].contains(month)) {
    return 'Осень';
  } else {
    return 'Зима';
  }
}

String getSeasonEng(int month) {
  if ([3, 4, 5].contains(month)) {
    return 'spring';
  } else if ([6, 7, 8].contains(month)) {
    return 'summer';
  } else if ([9, 10, 11].contains(month)) {
    return 'fall';
  } else {
    return 'winter';
  }
}

String getNextSeason(String season) {
  switch (season) {
    case 'spring':
      return 'summer';

    case 'summer':
      return 'fall';

    case 'fall':
      return 'winter';

    case 'winter':
      return 'spring';
    default:
      return '';
  }
}

// String getNextSeason() {
//   final currentDate = DateTime.now();
//   final currentMonth = currentDate.month;
//   final currentYear =
//       currentMonth == 12 ? currentDate.year + 1 : currentDate.year;

//   final season = getSeasonEng(currentMonth + 1);

//   return '${season}_$currentYear';
// }
