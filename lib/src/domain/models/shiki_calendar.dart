import 'package:shikidev/src/utils/extensions/string_ext.dart';

import 'animes.dart';

class ShikiCalendar {
  int? nextEpisode;
  String? nextEpisodeAt;
  DateTime? nextEpisodeDateTime;
  int? duration;
  Animes? anime;

  ShikiCalendar(
      {this.nextEpisode,
      this.nextEpisodeAt,
      this.nextEpisodeDateTime,
      this.duration,
      this.anime});

  ShikiCalendar.fromJson(Map<String, dynamic> json) {
    nextEpisode = json['next_episode'];
    nextEpisodeAt = json['next_episode_at'];
    nextEpisodeDateTime = (json['next_episode_at'].toString()).toDateTime;
    duration = json['duration'];
    anime = json['anime'] != null ? Animes.fromJson(json['anime']) : null;
  }
}
