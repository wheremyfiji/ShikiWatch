import 'package:shikidev/src/domain/models/user_rate.dart';

import 'anime.dart';
import 'animes.dart';
import 'manga_short.dart';
import 'user.dart';

class UserAnimeRates {
  int? id;
  int? score;
  String? status;
  String? text;
  int? episodes;
  int? chapters;
  int? volumes;
  String? textHtml;
  int? rewatches;
  String? createdAt;
  String? updatedAt;
  User? user;
  Animes? anime;
  MangaShort? manga;

  UserAnimeRates(
      {required this.id,
      required this.score,
      required this.status,
      this.text,
      required this.episodes,
      this.chapters,
      this.volumes,
      this.textHtml,
      required this.rewatches,
      required this.createdAt,
      required this.updatedAt,
      this.user,
      required this.anime,
      this.manga});

  UserAnimeRates.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        score = json['score'],
        status = json['status'],
        text = json['text'],
        episodes = json['episodes'],
        chapters = json['chapters'],
        volumes = json['volumes'],
        textHtml = json['text_html'],
        rewatches = json['rewatches'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        user = json['user'] == null ? null : User.fromJson(json['user']),
        anime = json['anime'] == null ? null : Animes.fromJson(json['anime']),
        manga =
            json['manga'] == null ? null : MangaShort.fromJson(json['manga']);
}

extension UserAnimeRatesExtension on UserAnimeRates {
  Anime get toAnime => Anime(
        id: anime!.id,
        name: anime!.name,
        russian: anime!.russian,
        url: anime!.url,
        image: anime!.image,
        kind: anime!.kind,
        score: anime!.score,
        status: anime!.status,
        airedOn: anime!.airedOn,
        releasedOn: anime!.releasedOn,
        episodes: anime!.episodes,
        episodesAired: anime!.episodes,
        userRate: UserRate(
          id: id,
          score: score,
          status: status,
          text: text,
          episodes: episodes,
          chapters: chapters,
          volumes: volumes,
          textHtml: textHtml,
          rewatches: rewatches,
          createdAt: createdAt,
          updatedAt: updatedAt,
        ),
      );
}
