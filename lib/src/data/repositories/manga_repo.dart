import 'package:dio/dio.dart';

import '../../domain/models/manga_ranobe.dart';

abstract class MangaRepository {
  const MangaRepository();

  Future<MangaRanobe> getManga({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  });
}
