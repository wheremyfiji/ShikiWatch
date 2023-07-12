import 'animes.dart';
import 'manga_short.dart';

class RelatedTitle {
  String? relation;
  String? relationRussian;
  Animes? anime;
  MangaShort? manga;
  String? type;

  RelatedTitle({
    this.relation,
    this.relationRussian,
    this.anime,
    this.manga,
    this.type,
  });

  RelatedTitle.fromJson(Map<String, dynamic> json) {
    relation = json['relation'];
    relationRussian = json['relation_russian'];
    anime = json['anime'] != null ? Animes.fromJson(json['anime']) : null;
    manga = json['manga'] != null ? MangaShort.fromJson(json['manga']) : null;
  }
}
