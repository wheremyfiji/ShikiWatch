import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/manga_ranobe.dart';
import '../../services/http/http_service_provider.dart';
import '../repositories/http_service.dart';
import '../repositories/manga_repo.dart';

final mangaDataSourceProvider = Provider<MangaDataSource>(
    (ref) => MangaDataSource(ref.read(httpServiceProvider)),
    name: 'mangaDataSourceProvider');

class MangaDataSource implements MangaRepository {
  final HttpService dio;

  MangaDataSource(this.dio);

  @override
  Future<MangaRanobe> getManga({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  }) async {
    final response = await dio.get(
      'mangas/$id',
      cancelToken: cancelToken,
      forceRefresh: forceRefresh,
      needToCache: needToCache,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return MangaRanobe.fromJson(response);
  }
}
