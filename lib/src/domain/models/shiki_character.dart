import 'animes.dart';
import 'manga_short.dart';
import 'shiki_image.dart';

class ShikiCharacter {
  final int? id;
  final String? name;
  final String? russian;
  final ShikiImage? image;
  final String? url;
  final String? altname;
  final String? japanese;
  final String? description;
  final String? descriptionHtml;
  final String? descriptionSource;
  final bool? favoured;
  final int? threadId;
  final int? topicId;
  final DateTime? updatedAt;
  final List<Seyu>? seyu;
  final List<Animes>? animes;
  final List<MangaShort>? mangas;

  ShikiCharacter({
    this.id,
    this.name,
    this.russian,
    this.image,
    this.url,
    this.altname,
    this.japanese,
    this.description,
    this.descriptionHtml,
    this.descriptionSource,
    this.favoured,
    this.threadId,
    this.topicId,
    this.updatedAt,
    this.seyu,
    this.animes,
    this.mangas,
  });

  factory ShikiCharacter.fromJson(Map<String, dynamic> json) => ShikiCharacter(
        id: json["id"],
        name: json["name"],
        russian: json["russian"],
        image:
            json["image"] == null ? null : ShikiImage.fromJson(json["image"]),
        url: json["url"],
        altname: json["altname"],
        japanese: json["japanese"],
        description: json["description"],
        descriptionHtml: json["description_html"],
        descriptionSource: json["description_source"],
        favoured: json["favoured"],
        threadId: json["thread_id"],
        topicId: json["topic_id"],
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        seyu: json["seyu"] == null
            ? []
            : List<Seyu>.from(json["seyu"]!.map((x) => Seyu.fromJson(x))),
        animes: json["animes"] == null
            ? []
            : List<Animes>.from(json["animes"]!.map((x) => Animes.fromJson(x))),
        mangas: json["mangas"] == null
            ? []
            : List<MangaShort>.from(
                json["mangas"]!.map((x) => MangaShort.fromJson(x))),
      );
}

class Seyu {
  final int? id;
  final String? name;
  final String? russian;
  final ShikiImage? image;
  final String? url;

  Seyu({
    this.id,
    this.name,
    this.russian,
    this.image,
    this.url,
  });

  factory Seyu.fromJson(Map<String, dynamic> json) => Seyu(
        id: json["id"],
        name: json["name"],
        russian: json["russian"],
        image:
            json["image"] == null ? null : ShikiImage.fromJson(json["image"]),
        url: json["url"],
      );
}
