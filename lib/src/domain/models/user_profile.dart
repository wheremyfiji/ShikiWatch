import 'user_image.dart';

class UserProfile {
  int? id;
  String? nickname;
  String? avatar;
  UserImages? image;
  String? lastOnlineAt;
  String? url;
  //Null? name;
  String? sex;
  //Null? fullYears;
  String? lastOnline;
  String? website;
  //Null? location;
  bool? banned;
  String? about;
  String? aboutHtml;
  List<String>? commonInfo;
  bool? showComments;
  bool? inFriends;
  bool? isIgnored;
  Stats? stats;
  int? styleId;

  UserProfile(
      {this.id,
      this.nickname,
      this.avatar,
      this.image,
      this.lastOnlineAt,
      this.url,
      //this.name,
      this.sex,
      //this.fullYears,
      this.lastOnline,
      this.website,
      //this.location,
      this.banned,
      this.about,
      this.aboutHtml,
      this.commonInfo,
      this.showComments,
      this.inFriends,
      this.isIgnored,
      this.stats,
      this.styleId});

  UserProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    avatar = json['avatar'];
    image = json['image'] != null ? UserImages.fromJson(json['image']) : null;
    lastOnlineAt = json['last_online_at'];
    url = json['url'];
    //name = json['name'];
    sex = json['sex'];
    //fullYears = json['full_years'];
    lastOnline = json['last_online'];
    website = json['website'];
    //location = json['location'];
    banned = json['banned'];
    about = json['about'];
    aboutHtml = json['about_html'];
    commonInfo = json['common_info'].cast<String>();
    showComments = json['show_comments'];
    inFriends = json['in_friends'];
    isIgnored = json['is_ignored'];
    stats = json['stats'] != null ? Stats.fromJson(json['stats']) : null;
    styleId = json['style_id'];
  }
}

class Stats {
  Statuses? statuses;
  //Statuses? fullStatuses;
  //Statuses? scores;
  //Statuses? types;
  //Ratings? ratings;
  bool? hasAnime;
  bool? hasManga;
  // List<Null>? genres;
  // List<Null>? studios;
  // List<Null>? publishers;
  //List<Activity>? activity;

  Stats({
    this.statuses,
    //this.fullStatuses,
    //this.scores,
    //this.types,
    //this.ratings,
    this.hasAnime,
    this.hasManga,
    // this.genres,
    // this.studios,
    // this.publishers,
    //this.activity
  });

  Stats.fromJson(Map<String, dynamic> json) {
    statuses =
        json['statuses'] != null ? Statuses.fromJson(json['statuses']) : null;
    // fullStatuses = json['full_statuses'] != null
    //     ? Statuses.fromJson(json['full_statuses'])
    //     : null;
    // scores = json['scores'] != null ? Statuses.fromJson(json['scores']) : null;
    // types = json['types'] != null ? Statuses.fromJson(json['types']) : null;
    // ratings =
    //     json['ratings'] != null ? Ratings.fromJson(json['ratings']) : null;
    hasAnime = json['has_anime?'];
    hasManga = json['has_manga?'];
    // if (json['genres'] != null) {
    //   genres = <Null>[];
    //   json['genres'].forEach((v) {
    //     genres!.add(Null.fromJson(v));
    //   });
    // }
    // if (json['studios'] != null) {
    //   studios = <Null>[];
    //   json['studios'].forEach((v) {
    //     studios!.add(Null.fromJson(v));
    //   });
    // }
    // if (json['publishers'] != null) {
    //   publishers = <Null>[];
    //   json['publishers'].forEach((v) {
    //     publishers!.add(Null.fromJson(v));
    //   });
    // }
    // if (json['activity'] != null) {
    //   activity = <Activity>[];
    //   json['activity'].forEach((v) {
    //     activity!.add(Activity.fromJson(v));
    //   });
    // }
  }
}

class Statuses {
  List<StatusesAnime>? anime;
  List<StatusesManga>? manga;

  Statuses({this.anime, this.manga});

  Statuses.fromJson(Map<String, dynamic> json) {
    if (json['anime'] != null) {
      anime = <StatusesAnime>[];
      json['anime'].forEach((v) {
        anime!.add(StatusesAnime.fromJson(v));
      });
    }
    if (json['manga'] != null) {
      manga = <StatusesManga>[];
      json['manga'].forEach((v) {
        manga!.add(StatusesManga.fromJson(v));
      });
    }
  }
}

class StatusesAnime {
  int? id;
  String? groupedId;
  String? name;
  int? size;
  String? type;

  StatusesAnime({this.id, this.groupedId, this.name, this.size, this.type});

  StatusesAnime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupedId = json['grouped_id'];
    name = json['name'];
    size = json['size'];
    type = json['type'];
  }
}

class StatusesManga {
  int? id;
  String? groupedId;
  String? name;
  int? size;
  String? type;

  StatusesManga({this.id, this.groupedId, this.name, this.size, this.type});

  StatusesManga.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupedId = json['grouped_id'];
    name = json['name'];
    size = json['size'];
    type = json['type'];
  }
}

class ScoresAnime {
  String? name;
  int? value;

  ScoresAnime({this.name, this.value});

  ScoresAnime.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}

class Ratings {
  List<StatusesAnime>? anime;

  Ratings({this.anime});

  Ratings.fromJson(Map<String, dynamic> json) {
    if (json['anime'] != null) {
      anime = <StatusesAnime>[];
      json['anime'].forEach((v) {
        anime!.add(StatusesAnime.fromJson(v));
      });
    }
  }
}

class Activity {
  List<int>? name;
  int? value;

  Activity({this.name, this.value});

  Activity.fromJson(Map<String, dynamic> json) {
    name = json['name'].cast<int>();
    value = json['value'];
  }
}
