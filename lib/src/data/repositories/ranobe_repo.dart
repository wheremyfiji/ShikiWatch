import 'package:dio/dio.dart';

import '../../domain/models/manga_ranobe.dart';

abstract class RanobeRepository {
  const RanobeRepository();

  Future<MangaRanobe> getRanobe({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  });
}
