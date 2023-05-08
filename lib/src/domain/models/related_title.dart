import 'animes.dart';
import 'manga_short.dart';

class RelatedTitle {
  String? relation;
  String? relationRussian;
  Animes? anime;
  MangaShort? manga;
  //Title? title;
  String? type;

  RelatedTitle({
    this.relation,
    this.relationRussian,
    //this.title,
    this.anime,
    this.manga,
    this.type,
  });

  RelatedTitle.fromJson(Map<String, dynamic> json) {
    relation = json['relation'];
    relationRussian = json['relation_russian'];
    // if (json['anime'] == null) {
    //   type = 'Манга';
    //   title = Title.fromJson(json['manga']);
    // } else {
    //   type = 'Аниме';
    //   title = Title.fromJson(json['anime']);
    // }
    //if ( json['manga'] == null) title = json['anime'] != null ? Title.fromJson(json['anime']) : null;
    anime = json['anime'] != null ? Animes.fromJson(json['anime']) : null;
    manga = json['manga'] != null ? MangaShort.fromJson(json['manga']) : null;
  }
}


// class Title {
//   int? id;
//   String? name;
//   String? russian;
//   ShikiImage? image;
//   String? url;
//   String? kind;
//   String? score;
//   String? status;
//   String? airedOn;
//   String? releasedOn;

//   Title.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     russian = json['russian'];
//     image = json['image'] != null ? ShikiImage.fromJson(json['image']) : null;
//     url = json['url'];
//     kind = json['kind'];
//     score = json['score'];
//     status = json['status'];
//     airedOn = json['aired_on'];
//     releasedOn = json['released_on'];
//   }
// }
