import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/anime.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/franchise.dart';
import '../../domain/models/related_title.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../domain/models/user_rate_resp.dart';
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
  //Future<UserProfile> getUserProfile() async {
  Future<Anime> getAnime({
    required int? id,
    String? token,
    CancelToken? cancelToken,
    bool forceRefresh = false,
    bool needToCache = false,
  }) async {
    if (token != null) {
      final response = await dio.get(
        'animes/$id',
        cancelToken: cancelToken,
        forceRefresh: forceRefresh,
        needToCache: needToCache,
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
        forceRefresh: forceRefresh,
        needToCache: needToCache,
      );

      return Anime.fromJson(response);
    }

    //final response = await dio.get('animes/$id');
    // return Anime.fromJson(response);
  }

  @override
  Future<Iterable<Animes>> getSimilarAnimes({required int? id}) async {
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
  Future<Franchise> getAnimeFranchise({
    required int? id,
  }) async {
    final response = await dio.get('animes/$id/franchise');

    return Franchise.fromJson(response);
  }

  @override
  Future<Iterable<Animes>> getAnimes(
      {int? page,
      int? limit,
      String? order,
      String? kind,
      String? status,
      String? season,
      int? score,
      String? duration,
      String? rating,
      String? mylist,
      String? censored,
      String? search,
      String? userToken}) async {
    final response = await dio.get(
      'animes',
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
  Future<Iterable<UserAnimeRates>> getUserAnimeRates(
      {required String? id,
      required String? token,
      int? page,
      int? limit,
      String? status,
      String? censored}) async {
    final response = await dio.get('users/$id/anime_rates',
        queryParameters: {
          if (page != null) 'page': page.toString(),
          if (limit != null) 'limit': limit.toString(),
          if (status != null) 'status': status,
          if (censored != null) 'censored': censored,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ));

    return [for (final e in response) UserAnimeRates.fromJson(e)];
  }

  @override
  Future<UserRateResp> createUserRate({
    required String token,
    required int userId,
    required int targetId,
    required String status,
    required int score,
    required int episodes,
    int? rewatches,
    String? text,
  }) async {
    final response = await dio.post(
      'v2/user_rates',
      data: {
        'user_rate': {
          'user_id': userId,
          'target_id': targetId,
          'target_type': 'Anime',
          'status': status,
          'score': score,
          'episodes': episodes,
          'rewatches': rewatches,
          'text': text,
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return UserRateResp.fromJson(response);
  }

  @override
  Future<UserRateResp> updateUserRate({
    required String token,
    required int rateId,
    String? status,
    int? score,
    int? episodes,
    int? rewatches,
    String? text,
  }) async {
    final response = await dio.path(
      'v2/user_rates/$rateId',
      data: {
        'user_rate': {
          if (status != null) 'status': status,
          if (score != null) 'score': score,
          if (episodes != null) 'episodes': episodes,
          if (rewatches != null) 'rewatches': rewatches,
          if (text != null) 'text': text,
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return UserRateResp.fromJson(response);
  }

  @override
  Future<UserRateResp> incrementUserRate({
    required String token,
    required int rateId,
  }) async {
    final response = await dio.post(
      'v2/user_rates/$rateId/increment',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return UserRateResp.fromJson(response);
  }

  @override
  Future<bool> deleteUserRate({
    required String token,
    required int rateId,
  }) async {
    final response = await dio.delete(
      'v2/user_rates/$rateId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    return response;
  }
}
