String getStatus(String value) {
  String status;

  const map = {'anons': 'Анонс', 'ongoing': 'Онгоинг', 'released': 'Вышло'};

  status = map[value] ?? 'N/A';

  return status;
}

// String getMangaRanobeStatus(String value) {
//   String status;

//   const map = {'anons': 'Анонс', 'ongoing': 'Выходит', 'released': 'Издано'};

//   status = map[value] ?? 'N/A';

//   return status;
// }

// String getKind(String value) {
//   String kind;

//   const map = {
//     'tv': 'TV',
//     'movie': 'Фильм',
//     'ova': 'OVA',
//     'ona': 'ONA',
//     'special': 'Спешл',
//     'music': 'Клип'
//   };

//   kind = map[value] ?? 'N/A';

//   return kind;
// }

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
  switch (month) {
    case 1:
      return 'Зима';
    case 2:
      return 'Зима';
    case 3:
      return 'Весна';
    case 4:
      return 'Весна';
    case 5:
      return 'Весна';
    case 6:
      return 'Лето';
    case 7:
      return 'Лето';
    case 8:
      return 'Лето';
    case 9:
      return 'Осень';
    case 10:
      return 'Осень';
    case 11:
      return 'Осень';
    case 12:
      return 'Зима';
    default:
      return '';
  }
}
