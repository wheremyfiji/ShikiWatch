import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/anime.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/external_link.dart';
import '../../domain/models/franchise.dart';
import '../../domain/models/related_title.dart';
import '../../domain/models/shiki_calendar.dart';
import '../repositories/anime_repo.dart';
import '../repositories/http_service.dart';
import '../../services/http/http_service_provider.dart';

final animeDataSourceProvider = Provider<AnimeDataSource>(
    (ref) => AnimeDataSource(ref.read(httpServiceProvider)),
    name: 'animeDataSourceProvider');

class AnimeDataSource implements AnimeRepository {
  final HttpService dio;
  AnimeDataSource(this.dio);

  @override
  Future<Anime> getAnime({
    required int? id,
    required CancelToken cancelToken,
    String? token,
    bool forceRefresh = false,
    bool needToCache = false,
  }) async {
    if (token != null) {
      final response = await dio.get(
        'animes/$id',
        cancelToken: cancelToken,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      return Anime.fromJson(response);
    } else {
      final response = await dio.get(
        'animes/$id',
        cancelToken: cancelToken,
      );

      return Anime.fromJson(response);
    }
  }

  @override
  Future<Iterable<Animes>> getSimilarAnimes({
    required int? id,
    required CancelToken cancelToken,
  }) async {
    final response = await dio.get('animes/$id/similar');

    return [for (final e in response) Animes.fromJson(e)];
  }

  @override
  Future<Iterable<RelatedTitle>> getRelatedTitlesAnime({
    required int? id,
    required CancelToken cancelToken,
  }) async {
    final response =
        await dio.get('animes/$id/related', cancelToken: cancelToken);

    return [for (final e in response) RelatedTitle.fromJson(e)];
  }

  @override
  Future<Iterable<ExternalLink>> getExternalLinks({
    required int? id,
    required CancelToken cancelToken,
  }) async {
    final response = await dio.get(
      'animes/$id/external_links',
      cancelToken: cancelToken,
    );

    return [for (final e in response) ExternalLink.fromJson(e)];
  }

  @override
  Future<Franchise> getAnimeFranchise({
    required int? id,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'animes/$id/franchise',
      cancelToken: cancelToken,
    );

    return Franchise.fromJson(response);
  }

  @override
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
  }) async {
    final response = await dio.get(
      'animes',
      cancelToken: cancelToken,
      queryParameters: {
        if (page != null) 'page': page.toString(),
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order,
        if (kind != null) 'kind': kind,
        if (status != null) 'status': status,
        if (season != null) 'season': season,
        if (score != null) 'score': score.toString(),
        if (duration != null) 'duration': duration,
        if (rating != null) 'rating': rating,
        if (genre != null) 'genre': genre,
        if (studio != null) 'studio': studio,
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

    return [for (final e in response) Animes.fromJson(e)];
  }

  @override
  Future<Iterable<ShikiCalendar>> getCalendar({
    bool censored = false,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'calendar',
      cancelToken: cancelToken,
      queryParameters: {
        'censored': 'true',
      },
    );

    return [for (final e in response) ShikiCalendar.fromJson(e)];
  }
}
