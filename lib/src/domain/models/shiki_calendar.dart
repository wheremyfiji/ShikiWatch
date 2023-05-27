import 'animes.dart';

class ShikiCalendar {
  int? nextEpisode;
  String? nextEpisodeAt;
  int? duration;
  Animes? anime;

  ShikiCalendar(
      {this.nextEpisode, this.nextEpisodeAt, this.duration, this.anime});

  ShikiCalendar.fromJson(Map<String, dynamic> json) {
    nextEpisode = json['next_episode'];
    nextEpisodeAt = json['next_episode_at'];
    duration = json['duration'];
    anime = json['anime'] != null ? Animes.fromJson(json['anime']) : null;
  }
}
