import 'genre.dart';
import 'publisher.dart';
import 'shiki_image.dart';
import 'user_rate.dart';

class MangaRanobe {
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
  List<String>? english;
  List<String>? japanese;
  List<String>? synonyms;
  //String? licenseNameRu;
  String? description;
  String? descriptionHtml;
  String? franchise;
  bool? favoured;
  bool? anons;
  bool? ongoing;
  int? threadId;
  int? topicId;
  int? myanimelistId;
  List<RatesScoresStats>? ratesScoresStats;
  List<RatesStatusesStats>? ratesStatusesStats;
  // "licensors": [],
  List<Genre>? genres;
  //  "publishers": [],
  List<Publisher>? publishers;
  UserRate? userRate;

  MangaRanobe({
    this.id,
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
    this.releasedOn,
    this.english,
    this.japanese,
    this.synonyms,
    //this.licenseNameRu,
    this.description,
    this.descriptionHtml,
    this.franchise,
    this.favoured,
    this.anons,
    this.ongoing,
    this.threadId,
    this.topicId,
    this.myanimelistId,
    this.ratesScoresStats,
    this.ratesStatusesStats,
    //this.licensors,
    this.genres,
    this.publishers,
    this.userRate,
  });

  MangaRanobe.fromJson(Map<String, dynamic> json) {
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
    english = json['english'].cast<String>();
    japanese = json['japanese'].cast<String>();
    synonyms = json['synonyms'].cast<String>();
    //licenseNameRu = json['license_name_ru'];
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
    if (json['genres'] != null) {
      genres = <Genre>[];
      json['genres'].forEach((v) {
        genres!.add(Genre.fromJson(v));
      });
    }
    if (json['publishers'] != null) {
      publishers = <Publisher>[];
      json['publishers'].forEach((v) {
        publishers!.add(Publisher.fromJson(v));
      });
    }
    userRate =
        json['user_rate'] != null ? UserRate.fromJson(json['user_rate']) : null;
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
