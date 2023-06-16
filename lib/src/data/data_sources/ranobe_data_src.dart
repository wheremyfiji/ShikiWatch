import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/manga_ranobe.dart';
import '../../domain/models/manga_short.dart';
import '../../services/http/http_service_provider.dart';
import '../repositories/http_service.dart';
import '../repositories/ranobe_repo.dart';

final ranobeDataSourceProvider = Provider<RanobeDataSource>(
    (ref) => RanobeDataSource(ref.read(httpServiceProvider)),
    name: 'ranobeDataSourceProvider');

class RanobeDataSource implements RanobeRepository {
  final HttpService dio;

  RanobeDataSource(this.dio);

  @override
  Future<MangaRanobe> getRanobeById({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  }) async {
    final response = await dio.get(
      'ranobe/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return MangaRanobe.fromJson(response);
  }

  @override
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
  }) async {
    final response = await dio.get(
      'ranobe',
      cancelToken: cancelToken,
      queryParameters: {
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order,
        if (kind != null) 'kind': kind,
        if (status != null) 'status': status,
        if (season != null) 'season': season,
        if (score != null) 'score': score.toString(),
        if (genre != null) 'genre': genre,
        if (censored != null) 'censored': censored,
        if (mylist != null) 'mylist': mylist,
        if (search != null) 'search': search,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      ),
    );

    return [for (final e in response) MangaShort.fromJson(e)];
  }
}
