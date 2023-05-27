import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

import '../../domain/models/external_link.dart';
import '../../domain/models/manga_ranobe.dart';
import '../../domain/models/manga_short.dart';
import '../../domain/models/related_title.dart';
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
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return MangaRanobe.fromJson(response);
  }

  @override
  Future<Iterable<ExternalLink>> getExternalLinks({
    required int? id,
    required CancelToken cancelToken,
  }) async {
    final response = await dio.get(
      'mangas/$id/external_links',
      cancelToken: cancelToken,
    );

    return [for (final e in response) ExternalLink.fromJson(e)];
  }

  @override
  Future<Iterable<RelatedTitle>> getRelatedTitles({
    required int? id,
    required CancelToken cancelToken,
  }) async {
    final response =
        await dio.get('mangas/$id/related', cancelToken: cancelToken);

    return [for (final e in response) RelatedTitle.fromJson(e)];
  }

  @override
  Future<Iterable<MangaShort>> getSimilar({
    required int? id,
    required CancelToken cancelToken,
  }) async {
    final response = await dio.get('mangas/$id/similar');

    return [for (final e in response) MangaShort.fromJson(e)];
  }

  @override
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
  }) async {
    final response = await dio.get(
      'mangas',
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
        //if (studio != null) 'studio': studio,
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
