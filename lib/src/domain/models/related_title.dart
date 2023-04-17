class RelatedTitle {
  String? relation;
  String? relationRussian;
  // Animes? anime;
  // Manga? manga;
  Title? title;
  String? type;

  RelatedTitle({this.relation, this.relationRussian, this.title, this.type});

  RelatedTitle.fromJson(Map<String, dynamic> json) {
    relation = json['relation'];
    relationRussian = json['relation_russian'];
    if (json['anime'] == null) {
      type = 'Манга';
      title = Title.fromJson(json['manga']);
    } else {
      type = 'Аниме';
      title = Title.fromJson(json['anime']);
    }
    //if ( json['manga'] == null) title = json['anime'] != null ? Title.fromJson(json['anime']) : null;
    //title = json['anime'] != null ? Title.fromJson(json['anime']) : null;
    //manga = json['manga'] != null ? Title.fromJson(json['manga']) : null;
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   data['relation'] = relation;
  //   data['relation_russian'] = relationRussian;
  //   if (anime != null) {
  //     data['anime'] = anime!.toJson();
  //   }
  //   if (manga != null) {
  //     data['manga'] = manga!.toJson();
  //   }
  //   return data;
  // }
}

// class Anime {
//   int? id;
//   String? name;
//   String? russian;
//   Image? image;
//   String? url;
//   String? kind;
//   String? score;
//   String? status;
//   int? episodes;
//   int? episodesAired;
//   String? airedOn;
//   String? releasedOn;

//   Anime(
//       {this.id,
//       this.name,
//       this.russian,
//       this.image,
//       this.url,
//       this.kind,
//       this.score,
//       this.status,
//       this.episodes,
//       this.episodesAired,
//       this.airedOn,
//       this.releasedOn});

//   Anime.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     name = json['name'];
//     russian = json['russian'];
//     image = json['image'] != null ? Image.fromJson(json['image']) : null;
//     url = json['url'];
//     kind = json['kind'];
//     score = json['score'];
//     status = json['status'];
//     episodes = json['episodes'];
//     episodesAired = json['episodes_aired'];
//     airedOn = json['aired_on'];
//     releasedOn = json['released_on'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id;
//     data['name'] = name;
//     data['russian'] = russian;
//     if (image != null) {
//       data['image'] = image!.toJson();
//     }
//     data['url'] = url;
//     data['kind'] = kind;
//     data['score'] = score;
//     data['status'] = status;
//     data['episodes'] = episodes;
//     data['episodes_aired'] = episodesAired;
//     data['aired_on'] = airedOn;
//     data['released_on'] = releasedOn;
//     return data;
//   }
// }

class Title {
  int? id;
  String? name;
  String? russian;
  XImage? image;
  String? url;
  String? kind;
  String? score;
  String? status;
  String? airedOn;
  String? releasedOn;

  Title.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    russian = json['russian'];
    image = json['image'] != null ? XImage.fromJson(json['image']) : null;
    url = json['url'];
    kind = json['kind'];
    score = json['score'];
    status = json['status'];
    airedOn = json['aired_on'];
    releasedOn = json['released_on'];
  }
}

class Manga {
  int? id;
  String? name;
  String? russian;
  XImage? image;
  String? url;
  String? kind;
  String? score;
  String? status;
  int? volumes;
  int? chapters;
  String? airedOn;
  String? releasedOn;

  Manga(
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

  Manga.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    russian = json['russian'];
    image = json['image'] != null ? XImage.fromJson(json['image']) : null;
    url = json['url'];
    kind = json['kind'];
    score = json['score'];
    status = json['status'];
    volumes = json['volumes'];
    chapters = json['chapters'];
    airedOn = json['aired_on'];
    releasedOn = json['released_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['russian'] = russian;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    data['url'] = url;
    data['kind'] = kind;
    data['score'] = score;
    data['status'] = status;
    data['volumes'] = volumes;
    data['chapters'] = chapters;
    data['aired_on'] = airedOn;
    data['released_on'] = releasedOn;
    return data;
  }
}

class XImage {
  String? original;
  String? preview;
  String? x96;
  String? x48;

  XImage({this.original, this.preview, this.x96, this.x48});

  XImage.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    preview = json['preview'];
    x96 = json['x96'];
    x48 = json['x48'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original'] = original;
    data['preview'] = preview;
    data['x96'] = x96;
    data['x48'] = x48;
    return data;
  }
}
