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
}
