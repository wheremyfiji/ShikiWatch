import 'animes.dart';
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
  //Null? manga;

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
      required this.anime
      //this.manga
      });

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
        anime = json['anime'] == null ? null : Animes.fromJson(json['anime']);
  //manga = json['manga'];
}
