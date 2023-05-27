import 'genre.dart';
import 'studio.dart';
import 'user_rate.dart';

class Anime {
  int? id;
  String? name;
  String? russian;
  Image? image;
  String? url;
  String? kind;
  String? score;
  String? status;
  int? episodes;
  int? episodesAired;
  String? airedOn;
  String? releasedOn;
  String? rating;
  List<String>? english;
  List<String>? japanese;
  List<String>? synonyms;
  //Null? licenseNameRu;
  int? duration;
  String? description;
  String? descriptionHtml;
  //Null? descriptionSource;
  String? franchise;
  bool? favoured;
  bool? anons;
  bool? ongoing;
  int? threadId;
  int? topicId;
  int? myanimelistId;
  List<RatesScoresStats>? ratesScoresStats;
  List<RatesStatusesStats>? ratesStatusesStats;
  String? updatedAt;
  String? nextEpisodeAt;
  List<String>? fansubbers;
  List<String>? fandubbers;
  //List<Null>? licensors;
  List<Genre>? genres;
  List<Studio>? studios;
  List<Videos>? videos;
  List<Screenshots>? screenshots;
  UserRate? userRate;

  Anime(
      {this.id,
      this.name,
      this.russian,
      this.image,
      this.url,
      this.kind,
      this.score,
      this.status,
      this.episodes,
      this.episodesAired,
      this.airedOn,
      this.releasedOn,
      this.rating,
      this.english,
      this.japanese,
      this.synonyms,
      //this.licenseNameRu,
      this.duration,
      this.description,
      this.descriptionHtml,
      //this.descriptionSource,
      this.franchise,
      this.favoured,
      this.anons,
      this.ongoing,
      this.threadId,
      this.topicId,
      this.myanimelistId,
      this.ratesScoresStats,
      this.ratesStatusesStats,
      this.updatedAt,
      this.nextEpisodeAt,
      this.fansubbers,
      this.fandubbers,
      //this.licensors,
      this.genres,
      this.studios,
      this.videos,
      this.screenshots,
      this.userRate});

  Anime.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    russian = json['russian'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    url = json['url'];
    kind = json['kind'];
    score = json['score'];
    status = json['status'];
    episodes = json['episodes'];
    episodesAired = json['episodes_aired'];
    airedOn = json['aired_on'];
    releasedOn = json['released_on'];
    rating = json['rating'];

    //english = json['english'].cast<String>();
    //japanese = json['japanese'].cast<String>();
    //synonyms = json['synonyms'].cast<String>();

    if (json['english'] != null) {
      english = <String>[];
      json['english'].forEach((v) {
        if (v != null) {
          english!.add(v);
        }
      });
    }
    if (json['japanese'] != null) {
      japanese = <String>[];
      json['japanese'].forEach((v) {
        if (v != null) {
          japanese!.add(v);
        }
      });
    }
    if (json['synonyms'] != null) {
      synonyms = <String>[];
      json['synonyms'].forEach((v) {
        if (v != null) {
          synonyms!.add(v);
        }
      });
    }

    //licenseNameRu = json['license_name_ru'];
    duration = json['duration'];
    description = json['description'];
    descriptionHtml = json['description_html'];
    //descriptionSource = json['description_source'];
    franchise = json['franchise'];
    favoured = json['favoured'];
    anons = json['anons'];
    ongoing = json['ongoing'];
    threadId = json['thread_id'];
    topicId = json['topic_id'];
    myanimelistId = json['myanimelist_id'];
    if (json['rates_scores_stats'] != null) {
      ratesScoresStats = <RatesScoresStats>[];
      json['rates_scores_stats'].forEach((v) {
        ratesScoresStats!.add(RatesScoresStats.fromJson(v));
      });
    }
    if (json['rates_statuses_stats'] != null) {
      ratesStatusesStats = <RatesStatusesStats>[];
      json['rates_statuses_stats'].forEach((v) {
        ratesStatusesStats!.add(RatesStatusesStats.fromJson(v));
      });
    }
    updatedAt = json['updated_at'];
    nextEpisodeAt = json['next_episode_at'];
    fansubbers = json['fansubbers'].cast<String>();
    fandubbers = json['fandubbers'].cast<String>();
    // if (json['licensors'] != null) {
    //   licensors = <Null>[];
    //   json['licensors'].forEach((v) {
    //     licensors!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['genres'] != null) {
      genres = <Genre>[];
      json['genres'].forEach((v) {
        genres!.add(Genre.fromJson(v));
      });
    }
    if (json['studios'] != null) {
      studios = <Studio>[];
      json['studios'].forEach((v) {
        studios!.add(Studio.fromJson(v));
      });
    }
    if (json['videos'] != null) {
      videos = <Videos>[];
      json['videos'].forEach((v) {
        videos!.add(Videos.fromJson(v));
      });
    }
    if (json['screenshots'] != null) {
      screenshots = <Screenshots>[];
      json['screenshots'].forEach((v) {
        screenshots!.add(Screenshots.fromJson(v));
      });
    }
    userRate =
        json['user_rate'] != null ? UserRate.fromJson(json['user_rate']) : null;
  }
}

class Image {
  String? original;
  String? preview;
  String? x96;
  String? x48;

  Image({this.original, this.preview, this.x96, this.x48});

  Image.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    preview = json['preview'];
    x96 = json['x96'];
    x48 = json['x48'];
  }
}

class RatesScoresStats {
  int? name;
  int? value;

  RatesScoresStats({this.name, this.value});

  RatesScoresStats.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}

class RatesStatusesStats {
  String? name;
  int? value;

  RatesStatusesStats({this.name, this.value});

  RatesStatusesStats.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}

class Videos {
  int? id;
  String? url;
  String? imageUrl;
  String? playerUrl;
  String? name;
  String? kind;
  String? hosting;

  Videos(
      {this.id,
      this.url,
      this.imageUrl,
      this.playerUrl,
      this.name,
      this.kind,
      this.hosting});

  Videos.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    url = json['url'];
    imageUrl = json['image_url'];
    playerUrl = json['player_url'];
    name = json['name'];
    kind = json['kind'];
    hosting = json['hosting'];
  }
}

class Screenshots {
  String? original;
  String? preview;

  Screenshots({this.original, this.preview});

  Screenshots.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    preview = json['preview'];
  }
}
