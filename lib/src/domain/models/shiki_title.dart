import 'animes.dart';
import 'manga_short.dart';
import 'shiki_image.dart';

class ShikiTitle {
  final int? id;
  final String? name;
  final String? russian;
  final String? url;
  final ShikiImage? image;
  final String? kind;
  final String? score;
  final String? status;
  final int? episodes;
  final int? episodesAired;
  final int? volumes;
  final int? chapters;
  final String? airedOn;
  final String? releasedOn;

  ShikiTitle(
      {required this.id,
      required this.name,
      required this.russian,
      required this.url,
      required this.image,
      required this.kind,
      required this.score,
      required this.status,
      required this.episodes,
      required this.episodesAired,
      required this.volumes,
      required this.chapters,
      required this.airedOn,
      required this.releasedOn});

  ShikiTitle.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        russian = json['russian'],
        url = json['url'],
        image =
            json['image'] == null ? null : ShikiImage.fromJson(json['image']),
        kind = json['kind'],
        score = json['score'],
        status = json['status'],
        episodes = json['episodes'],
        episodesAired = json['episodes_aired'],
        volumes = json['episodes'],
        chapters = json['episodes_aired'],
        airedOn = json['aired_on'],
        releasedOn = json['released_on'];
}

extension ShikiTitleExtension on ShikiTitle {
  Animes get toAnimes => Animes(
        id: id,
        name: name,
        russian: russian,
        url: url,
        image: image,
        kind: kind,
        score: score,
        status: status,
        airedOn: airedOn,
        releasedOn: releasedOn,
        episodes: episodes,
        episodesAired: episodes,
      );

  MangaShort get toMangaShort => MangaShort(
        id: id,
        name: name,
        russian: russian,
        url: url,
        image: image,
        kind: kind,
        score: score,
        status: status,
        airedOn: airedOn,
        releasedOn: releasedOn,
        volumes: volumes,
        chapters: chapters,
      );
}
