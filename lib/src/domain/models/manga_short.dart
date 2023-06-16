import 'shiki_image.dart';
import 'shiki_title.dart';

class MangaShort {
  int? id;
  String? name;
  String? russian;
  ShikiImage? image;
  String? url;
  String? kind;
  String? score;
  String? status;
  int? volumes;
  int? chapters;
  String? airedOn;
  String? releasedOn;

  MangaShort(
      {this.id,
      this.name,
      this.russian,
      this.image,
      this.url,
      this.kind,
      this.score,
      this.status,
      this.volumes,
      this.chapters,
      this.airedOn,
      this.releasedOn});

  MangaShort.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    russian = json['russian'];
    image = json['image'] != null ? ShikiImage.fromJson(json['image']) : null;
    url = json['url'];
    kind = json['kind'];
    score = json['score'];
    status = json['status'];
    volumes = json['volumes'];
    chapters = json['chapters'];
    airedOn = json['aired_on'];
    releasedOn = json['released_on'];
  }
}

extension MangaShortExtension on MangaShort {
  ShikiTitle get toShikiTitle => ShikiTitle(
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
        episodes: null,
        episodesAired: null,
      );
}
