import 'dart:convert';
import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../../domain/models/graphql_user_rate.dart';
import '../../../services/secure_storage/secure_storage_service.dart';
import '../../../services/http/http_service_provider.dart';
import '../../../domain/enums/shiki_gql.dart';

import 'graphql_character.dart';

final animeDetailsProvider = AsyncNotifierProvider.autoDispose
    .family<DetailsNotifier, GraphqlAnime, int>(
  DetailsNotifier.new,
  name: 'animeDetailsProvider',
);

class DetailsNotifier
    extends AutoDisposeFamilyAsyncNotifier<GraphqlAnime, int> {
  DetailsNotifier() : cancelToken = CancelToken();

  final CancelToken cancelToken;

  @override
  Future<GraphqlAnime> build(int arg) async {
    ref.onDispose(() {
      cancelToken.cancel();
    });

    return await _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      return await _fetch();
    });
  }

  void addRate({
    required int id,
    required String status,
    required int score,
    required int episodes,
    required int rewatches,
    required String text,
    required String textHtml,
    required String createdAt,
    required String updatedAt,
  }) {
    if (!state.hasValue) return;

    final prev = state.value!;

    final rate = GraphqlUserRate(
      id: id,
      status: RateStatus.fromValue(status),
      episodes: episodes,
      rewatches: rewatches,
      score: score,
      text: text,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );

    state = AsyncData(
      prev.copyWith(
        userRate: rate,
      ),
    );
  }

  void updateRate({
    required String status,
    required int score,
    required int episodes,
    required int rewatches,
    required String text,
    required String textHtml,
    required String updatedAt,
  }) {
    if (!state.hasValue) return;

    final prev = state.value!;

    state = AsyncData(
      prev.copyWith(
        userRate: prev.userRate!.copyWith(
          status: RateStatus.fromValue(status),
          score: score,
          episodes: episodes,
          rewatches: rewatches,
          text: text,
          updatedAt: DateTime.parse(updatedAt),
        ),
      ),
    );
  }

  void deleteRate() {
    if (!state.hasValue) return;

    final prev = state.value!;

    state = AsyncData(
      prev.copyWith(
        deleteRate: true,
      ),
    );
  }

  Future<GraphqlAnime> _fetch() async {
    final Map<String, dynamic> resp = await ref.read(httpServiceProvider).post(
          'https://shikimori.one/api/graphql',
          data: json.encode(
            {
              'query': _animeDetailsQuery,
              'variables': {
                'title_id': arg.toString(),
              },
            },
          ),
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${SecureStorageService.instance.token}',
            },
          ),
          cancelToken: cancelToken,
        );

    if (resp.containsKey('errors')) {
      final error = (resp['errors'] as List<dynamic>).first['message'];

      throw error;
    }

    if (resp['data']?['animes'] is! List<dynamic>) {
      throw 'broken response';
    }

    final list = resp['data']['animes'] as List<dynamic>;

    final anime = GraphqlAnime.fromJson(list.first);

    return anime;
  }
}

const _animeDetailsQuery = r'''
query($title_id: String) {
  animes(ids: $title_id) {
    id
    name
    url
    russian
    english
    japanese
    synonyms
    kind
    rating
    score
    status
    episodes
    episodesAired
    duration
    season
    origin

    nextEpisodeAt
    isCensored

    licensors

    airedOn { date }
    releasedOn { date }

    poster {
      originalUrl
      mainUrl
    }

    topic {
      id
      commentsCount
    }

    genres {
      id
      kind
      russian
    }

    studios {
      id
      name
    }

    statusesStats {
      count
      status
    }

    characterRoles {
      rolesRu
      character {
        id
        name
        russian
        poster {
          mainUrl
        }
      }
    }

    related {
      relationText
      anime {
        id
        name
        russian
        kind
        poster {
      		mainUrl
    		}
      }
      manga {
        id
        name
        russian
        kind
        poster {
      		mainUrl
    		}
      }
    }

    userRate {
      id
      status
      episodes
      rewatches
      score
      text
      createdAt
      updatedAt
    }

    description
    descriptionHtml

    screenshots { originalUrl x332Url }
  }
}
''';

@immutable
class GraphqlAnime {
  final int id;
  final String name;
  final String url;
  final Poster poster;
  final GraphqlTopic? topic;
  final String? russian;
  final String? english;
  final String? japanese;
  final List<String> synonyms;
  final TitleKind kind;
  final AnimeRating rating;
  final double score;
  final AnimeStatus status;

  final String? airedOn;
  final String? releasedOn;

  final int episodes;
  final int episodesAired;
  final int duration;
  final String season;
  final AnimeOrigin origin;

  final bool isCensored;

  final List<String> licensors;

  final DateTime? nextEpisodeAt;

  final String description;
  final int descriptionLength;

  final List<CharacterRole> characterRoles;
  final List<GraphqlGenre> genres;
  final List<GraphqlStudio> studios;
  final List<GraphqlRelated> related;
  final List<GraphqlStatusesStats> statusesStats;
  final List<GraphqlScreenshot> screenshots;
  final GraphqlUserRate? userRate;

  const GraphqlAnime({
    required this.id,
    required this.name,
    required this.url,
    required this.poster,
    required this.topic,
    required this.russian,
    required this.english,
    required this.japanese,
    required this.synonyms,
    required this.kind,
    required this.rating,
    required this.score,
    required this.status,
    required this.airedOn,
    required this.releasedOn,
    required this.episodes,
    required this.episodesAired,
    required this.duration,
    required this.season,
    required this.origin,
    required this.isCensored,
    required this.licensors,
    required this.nextEpisodeAt,
    required this.description,
    required this.descriptionLength,
    required this.characterRoles,
    required this.genres,
    required this.studios,
    required this.related,
    required this.statusesStats,
    required this.screenshots,
    required this.userRate,
  });

  factory GraphqlAnime.fromJson(Map<String, dynamic> json) => GraphqlAnime(
        id: int.parse(json["id"]),
        name: json["name"],
        url: json["url"],
        poster: Poster.fromJson(json["poster"]),
        topic:
            json["topic"] == null ? null : GraphqlTopic.fromJson(json["topic"]),
        russian: json["russian"],
        english: json["english"],
        japanese: json["japanese"],
        synonyms: json["synonyms"] == null
            ? []
            : List<String>.from(json["synonyms"].map((x) => x)),
        kind: TitleKind.fromValue(json["kind"] ?? 'unknown'),
        rating: AnimeRating.fromValue(json["rating"] ?? 'none'),
        score: json["score"] ?? 0.0,
        status: AnimeStatus.fromValue(json["status"] ?? 'unknown'),
        airedOn: json["airedOn"]?["date"],
        releasedOn: json["releasedOn"]?["date"],
        episodes: json["episodes"] ?? 0,
        episodesAired: json["episodesAired"] ?? 0,
        duration: json["duration"] ?? 0,
        season: json["season"] ?? '?',
        origin: AnimeOrigin.fromValue(json["origin"] ?? 'unknown'),
        isCensored: json["isCensored"] ?? false,
        licensors: json["licensors"] == null
            ? []
            : List<String>.from(json["licensors"].map((x) => x)),
        nextEpisodeAt: json["nextEpisodeAt"] == null
            ? null
            : DateTime.tryParse(json["nextEpisodeAt"]),
        description: json["descriptionHtml"] ?? '',
        descriptionLength: (json["description"] is String)
            ? (json["description"] as String).length
            : 0,
        characterRoles: json["characterRoles"] == null
            ? []
            : List<CharacterRole>.from(
                json["characterRoles"].map((x) => CharacterRole.fromJson(x))),
        genres: json["genres"] == null
            ? []
            : List<GraphqlGenre>.from(
                json["genres"].map((x) => GraphqlGenre.fromJson(x))),
        studios: json["studios"] == null
            ? []
            : List<GraphqlStudio>.from(
                json["studios"].map((x) => GraphqlStudio.fromJson(x))),
        related: json["related"] == null
            ? []
            : List<GraphqlRelated>.from(
                json["related"].map((x) => GraphqlRelated.fromJson(x))),
        statusesStats: List<GraphqlStatusesStats>.from(
            json["statusesStats"].map((x) => GraphqlStatusesStats.fromJson(x))),
        screenshots: json["screenshots"] == null
            ? []
            : List<GraphqlScreenshot>.from(
                json["screenshots"].map((x) => GraphqlScreenshot.fromJson(x))),
        userRate: json["userRate"] == null
            ? null
            : GraphqlUserRate.fromJson(json["userRate"]),
      );

  GraphqlAnime copyWith({
    int? id,
    String? name,
    String? url,
    Poster? poster,
    GraphqlTopic? topic,
    String? russian,
    String? english,
    String? japanese,
    List<String>? synonyms,
    TitleKind? kind,
    AnimeRating? rating,
    double? score,
    AnimeStatus? status,
    String? airedOn,
    String? releasedOn,
    int? episodes,
    int? episodesAired,
    int? duration,
    String? season,
    AnimeOrigin? origin,
    bool? isCensored,
    List<String>? licensors,
    DateTime? nextEpisodeAt,
    String? description,
    int? descriptionLength,
    List<CharacterRole>? characterRoles,
    List<GraphqlGenre>? genres,
    List<GraphqlStudio>? studios,
    List<GraphqlRelated>? related,
    List<GraphqlStatusesStats>? statusesStats,
    List<GraphqlScreenshot>? screenshots,
    GraphqlUserRate? userRate,
    bool deleteRate = false,
  }) {
    return GraphqlAnime(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      poster: poster ?? this.poster,
      topic: topic ?? this.topic,
      russian: russian ?? this.russian,
      english: english ?? this.english,
      japanese: japanese ?? this.japanese,
      synonyms: synonyms ?? this.synonyms,
      kind: kind ?? this.kind,
      rating: rating ?? this.rating,
      score: score ?? this.score,
      status: status ?? this.status,
      airedOn: airedOn ?? this.airedOn,
      releasedOn: releasedOn ?? this.releasedOn,
      episodes: episodes ?? this.episodes,
      episodesAired: episodesAired ?? this.episodesAired,
      duration: duration ?? this.duration,
      season: season ?? this.season,
      origin: origin ?? this.origin,
      isCensored: isCensored ?? this.isCensored,
      licensors: licensors ?? this.licensors,
      nextEpisodeAt: nextEpisodeAt ?? this.nextEpisodeAt,
      description: description ?? this.description,
      descriptionLength: descriptionLength ?? this.descriptionLength,
      characterRoles: characterRoles ?? this.characterRoles,
      genres: genres ?? this.genres,
      studios: studios ?? this.studios,
      related: related ?? this.related,
      statusesStats: statusesStats ?? this.statusesStats,
      screenshots: screenshots ?? this.screenshots,
      userRate: deleteRate ? null : userRate ?? this.userRate,
    );
  }

  @override
  bool operator ==(covariant GraphqlAnime other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.url == url &&
        other.poster == poster &&
        other.topic == topic &&
        other.russian == russian &&
        other.english == english &&
        other.japanese == japanese &&
        listEquals(other.synonyms, synonyms) &&
        other.kind == kind &&
        other.rating == rating &&
        other.score == score &&
        other.status == status &&
        other.airedOn == airedOn &&
        other.releasedOn == releasedOn &&
        other.episodes == episodes &&
        other.episodesAired == episodesAired &&
        other.duration == duration &&
        other.season == season &&
        other.origin == origin &&
        other.isCensored == isCensored &&
        listEquals(other.licensors, licensors) &&
        other.nextEpisodeAt == nextEpisodeAt &&
        other.description == description &&
        other.descriptionLength == descriptionLength &&
        listEquals(other.characterRoles, characterRoles) &&
        listEquals(other.genres, genres) &&
        listEquals(other.studios, studios) &&
        listEquals(other.related, related) &&
        listEquals(other.statusesStats, statusesStats) &&
        listEquals(other.screenshots, screenshots) &&
        other.userRate == userRate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        url.hashCode ^
        poster.hashCode ^
        topic.hashCode ^
        russian.hashCode ^
        english.hashCode ^
        japanese.hashCode ^
        synonyms.hashCode ^
        kind.hashCode ^
        rating.hashCode ^
        score.hashCode ^
        status.hashCode ^
        airedOn.hashCode ^
        releasedOn.hashCode ^
        episodes.hashCode ^
        episodesAired.hashCode ^
        duration.hashCode ^
        season.hashCode ^
        origin.hashCode ^
        isCensored.hashCode ^
        licensors.hashCode ^
        nextEpisodeAt.hashCode ^
        description.hashCode ^
        descriptionLength.hashCode ^
        characterRoles.hashCode ^
        genres.hashCode ^
        studios.hashCode ^
        related.hashCode ^
        statusesStats.hashCode ^
        screenshots.hashCode ^
        userRate.hashCode;
  }
}

class GraphqlTopic {
  final int id;
  final int commentsCount;

  GraphqlTopic({
    required this.id,
    required this.commentsCount,
  });

  factory GraphqlTopic.fromJson(Map<String, dynamic> json) => GraphqlTopic(
        id: int.parse(json["id"]),
        commentsCount: json["commentsCount"] ?? 0,
      );
}

enum RelatedType {
  anime,
  manga,
  unknown,
}

class GraphqlRelated {
  final RelatedType type;
  final String relationRu;
  final GraphqlRelatedTitle? title;

  GraphqlRelated({
    required this.type,
    required this.relationRu,
    required this.title,
  });

  factory GraphqlRelated.fromJson(Map<String, dynamic> json) {
    GraphqlRelatedTitle? title;
    RelatedType type = RelatedType.unknown;

    if (json["anime"] != null) {
      type = RelatedType.anime;
      title = GraphqlRelatedTitle.fromJson(json["anime"]);
    }

    if (json["manga"] != null) {
      type = RelatedType.manga;
      title = GraphqlRelatedTitle.fromJson(json["manga"]);
    }

    return GraphqlRelated(
      relationRu: json["relationText"],
      type: type,
      title: title,
    );
  }
}

class GraphqlRelatedTitle {
  final int id;
  final String name;
  final String? russian;
  final String poster;
  final TitleKind kind;

  GraphqlRelatedTitle({
    required this.id,
    required this.name,
    required this.russian,
    required this.poster,
    required this.kind,
  });

  factory GraphqlRelatedTitle.fromJson(Map<String, dynamic> json) =>
      GraphqlRelatedTitle(
        id: int.parse(json["id"]),
        name: json["name"],
        russian: json["russian"],
        poster: json["poster"]["mainUrl"],
        kind: TitleKind.fromValue(json["kind"] ?? 'unknown'),
      );
}

class GraphqlScreenshot {
  String originalUrl;
  String x332Url;

  GraphqlScreenshot({
    required this.originalUrl,
    required this.x332Url,
  });

  factory GraphqlScreenshot.fromJson(Map<String, dynamic> json) =>
      GraphqlScreenshot(
        originalUrl: json["originalUrl"],
        x332Url: json["x332Url"],
      );
}

class GraphqlStatusesStats {
  final int count;
  final RateStatus status;

  GraphqlStatusesStats({
    required this.count,
    required this.status,
  });

  factory GraphqlStatusesStats.fromJson(Map<String, dynamic> json) =>
      GraphqlStatusesStats(
        count: json["count"],
        status: RateStatus.fromValue(json["status"]),
      );
}

class GraphqlStudio {
  final int id;
  final String name;

  GraphqlStudio({
    required this.id,
    required this.name,
  });

  factory GraphqlStudio.fromJson(Map<String, dynamic> json) => GraphqlStudio(
        id: int.parse(json["id"]),
        name: json["name"],
      );
}

class GraphqlGenre {
  final int id;
  final GenreKind kind;
  final String russian;

  GraphqlGenre({
    required this.id,
    required this.kind,
    required this.russian,
  });

  factory GraphqlGenre.fromJson(Map<String, dynamic> json) => GraphqlGenre(
        id: int.parse(json["id"]),
        kind: GenreKind.fromValue(json["kind"]),
        russian: json["russian"],
      );
}

class Poster {
  final String? originalUrl;
  final String? mainUrl;

  Poster({
    this.originalUrl,
    this.mainUrl,
  });

  factory Poster.fromJson(Map<String, dynamic> json) => Poster(
        originalUrl: json["originalUrl"],
        mainUrl: json["mainUrl"],
      );
}
