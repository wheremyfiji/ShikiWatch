import 'package:dio/dio.dart';

import '../../domain/models/anime.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/external_link.dart';
import '../../domain/models/franchise.dart';
import '../../domain/models/related_title.dart';
import '../../domain/models/shiki_calendar.dart';

abstract class AnimeRepository {
  const AnimeRepository();

  Future<Anime> getAnime({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  });

  Future<Iterable<Animes>> getSimilarAnimes({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<Franchise> getAnimeFranchise({
    required int? id,
    CancelToken? cancelToken,
  });

  Future<Iterable<RelatedTitle>> getRelatedTitlesAnime({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<Iterable<ExternalLink>> getExternalLinks({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<Iterable<Animes>> getAnimes({
    int? page,
    int? limit,
    String? order,
    String? kind,
    String? status,
    String? season,
    int? score,
    String? duration,
    String? rating,
    String? genre,
    String? studio,
    String? mylist,
    String? censored,
    String? search,
    String? userToken,
    CancelToken? cancelToken,
  });

  Future<Iterable<ShikiCalendar>> getCalendar({
    bool censored = false,
    CancelToken? cancelToken,
  });
}
