import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/shiki_club.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../domain/models/user_history.dart';
import '../../domain/models/user_rate_resp.dart';
import '../repositories/user_repo.dart';
import '../repositories/http_service.dart';
import '../../domain/models/user_profile.dart';
import '../../services/http/http_service_provider.dart';

final userDataSourceProvider = Provider<UserDataSource>(
    (ref) => UserDataSource(ref.read(httpServiceProvider)),
    name: 'userDataSourceProvider');

class UserDataSource implements UserRepository {
  final HttpService dio;
  UserDataSource(this.dio);

  @override
  Future<Iterable<User>> getUsers({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'users',
      cancelToken: cancelToken,
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search != null) 'search': search,
      },
    );

    return [for (final e in response) User.fromJson(e)];
  }

  @override
  Future<UserProfile> getUserProfile({
    required String? id,
    String? userToken,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'users/$id',
      cancelToken: cancelToken,
      options: Options(
        headers: {
          'Authorization': 'Bearer $userToken',
        },
      ),
    );

    return UserProfile.fromJson(response);
  }

  @override
  Future<Iterable<User>> getUserFriends({
    required String? id,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      'users/$id/friends',
      cancelToken: cancelToken,
    );

    return [for (final e in response) User.fromJson(e)];
  }

  @override
  Future<Iterable<UserAnimeRates>> getUserAnimeRates({
    required String? id,
    required String? token,
    int? page,
    int? limit,
    String? status,
    String? censored,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get('users/$id/anime_rates',
        cancelToken: cancelToken,
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
  Future<Iterable<UserAnimeRates>> getUserMangaRates({
    required String? id,
    required String? token,
    int? page,
    int? limit,
    String? status,
    String? censored,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get('users/$id/manga_rates',
        cancelToken: cancelToken,
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
  Future<Iterable<UserHistory>> getHistory({
    required String id,
    required String token,
    required int page,
    required int limit,
    int? targetId,
    String? targetType,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get('users/$id/history',
        cancelToken: cancelToken,
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (targetId != null) 'target_id': targetType,
          if (targetType != null) 'target_type': targetType,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));

    return [for (final e in response) UserHistory.fromJson(e)];
  }

  @override
  Future<Iterable<ShikiClub>> getClubs({
    required String id,
    required String token,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get('users/$id/clubs',
        cancelToken: cancelToken,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));

    return [for (final e in response) ShikiClub.fromJson(e)];
  }

  @override
  Future<UserRateResp> createUserRate({
    required String token,
    required int userId,
    required int targetId,
    required String status,
    String? targetType = 'Anime',
  }) async {
    final response = await dio.post(
      'v2/user_rates',
      data: {
        'user_rate': {
          'user_id': userId,
          'target_id': targetId,
          'target_type': targetType,
          'status': status,
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
    int? chapters,
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
          if (chapters != null) 'chapters': chapters,
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
