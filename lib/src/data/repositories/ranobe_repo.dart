import 'package:dio/dio.dart';

import '../../domain/models/manga_ranobe.dart';
import '../../domain/models/manga_short.dart';

abstract class RanobeRepository {
  const RanobeRepository();

  Future<MangaRanobe> getRanobeById({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  });

  Future<Iterable<MangaShort>> getRanobe({
    int? page,
    int? limit,
    String? order,
    String? kind,
    String? status,
    String? season,
    int? score,
    String? genre,
    String? mylist,
    String? censored,
    String? search,
    String? userToken,
    CancelToken? cancelToken,
  });
}
