import 'dart:convert' as convert;

import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart' as url_launcher;
import 'package:go_router/go_router.dart';

import '../domain/models/pages_extra.dart';

class ShikiUtils {
  ShikiUtils._();

  static final ShikiUtils _instance = ShikiUtils._();

  static ShikiUtils get instance => _instance;

  static const List<String> _allowedType = ['anime', 'manga', 'character'];

  void handleShikiHtmlLinkTap(
    BuildContext ctx, {
    required String url,
    required Map<String, String> attributes,
  }) {
    //print('url: $url\n attributes: $attributes\n');
    final dataAttrs = attributes['data-attrs'];

    if (dataAttrs == null || dataAttrs.isEmpty) {
      url_launcher.launchUrlString(
        url,
        mode: url_launcher.LaunchMode.externalApplication,
      );
      return;
    }

    final jsonData = convert.json.decode(dataAttrs);

    if (jsonData['type'] is! String ||
        !_allowedType.contains(jsonData['type'])) {
      url_launcher.launchUrlString(
        url,
        mode: url_launcher.LaunchMode.externalApplication,
      );
      return;
    }

    final id = jsonData['id'];

    switch (jsonData['type']) {
      case 'anime':
        {
          final extra = AnimeDetailsPageExtra(
            id: id,
            label: jsonData['russian'] ?? jsonData['name'] ?? '[Без названия]',
          );

          ctx.pushNamed(
            'library_anime',
            pathParameters: <String, String>{
              'id': id.toString(),
            },
            extra: extra,
          );
        }
      case 'manga':
        {
          // final extra = AnimeDetailsPageExtra(
          //   id: id,
          //   label: jsonData['russian'] ?? jsonData['name'] ?? '[Без названия]',
          // );

          // ctx.pushNamed(
          //   'library_manga',
          //   pathParameters: <String, String>{
          //     'id': id.toString(),
          //   },
          //   extra: extra,
          // );
        }
      case 'character':
        {
          ctx.pushNamed(
            'character',
            pathParameters: <String, String>{
              'id': id.toString(),
            },
          );
        }
    }
  }
}

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
