import 'shiki_image.dart';

class Animes {
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
  final String? airedOn;
  final String? releasedOn;

  Animes(
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
      required this.airedOn,
      required this.releasedOn});

  Animes.fromJson(Map<String, dynamic> json)
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
        airedOn = json['aired_on'],
        releasedOn = json['released_on'];
}
