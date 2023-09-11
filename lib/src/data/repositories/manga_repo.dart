import 'package:dio/dio.dart';

import '../../domain/models/external_link.dart';
import '../../domain/models/manga_ranobe.dart';
import '../../domain/models/manga_short.dart';
import '../../domain/models/related_title.dart';
import '../../domain/models/shiki_role.dart';

abstract class MangaRepository {
  const MangaRepository();

  Future<MangaRanobe> getManga({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  });

  Future<Iterable<ExternalLink>> getExternalLinks({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<Iterable<RelatedTitle>> getRelatedTitles({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<Iterable<MangaShort>> getSimilar({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<List<ShikiRole>> getMangaRoles({
    required int? id,
    required CancelToken cancelToken,
  });

  Future<Iterable<MangaShort>> getMangas({
    int? page,
    int? limit,
    String? order,
    String? kind,
    String? status,
    String? season,
    int? score,
    String? genre,
    //String? studio,
    String? mylist,
    String? censored,
    String? search,
    String? userToken,
    CancelToken? cancelToken,
  });
}
