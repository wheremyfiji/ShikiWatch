String getStatus(String value) {
  String status;

  const map = {'anons': 'Анонс', 'ongoing': 'Онгоинг', 'released': 'Вышло'};

  status = map[value] ?? 'N/A';

  return status;
}

String getKind(String value) {
  String kind;

  const map = {
    'tv': 'TV',
    'movie': 'Фильм',
    'ova': 'OVA',
    'ona': 'ONA',
    'special': 'Спешл',
    'music': 'Клип',
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
    return 'autumn';
  } else {
    return 'winter';
  }
}

String getNextSeason() {
  final currentYear = DateTime.now().year;
  final currentMonth = DateTime.now().month;
  final season = getSeasonEng(currentMonth + 1);

  return '${season}_$currentYear';
}
