import 'package:dio/dio.dart';

import '../../domain/models/external_link.dart';
import '../../domain/models/manga_ranobe.dart';
import '../../domain/models/manga_short.dart';
import '../../domain/models/related_title.dart';

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
}
