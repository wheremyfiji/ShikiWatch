import 'package:dio/dio.dart';

import '../../domain/models/shiki_club.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../domain/models/user_history.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_rate_resp.dart';

abstract class UserRepository {
  const UserRepository();

  Future<Iterable<User>> getUsers({
    required int page,
    required int limit,
    String? search,
    CancelToken? cancelToken,
  });

  Future<UserProfile> getUserProfile({
    required String? id,
    String? userToken,
    CancelToken? cancelToken,
  });

  Future<Iterable<User>> getUserFriends({
    required String? id,
    CancelToken? cancelToken,
  });

  Future<Iterable<UserAnimeRates>> getUserAnimeRates({
    required String? id,
    required String? token,
    int? page,
    int? limit,
    String? status,
    String? censored,
    CancelToken? cancelToken,
  });

  Future<Iterable<UserAnimeRates>> getUserMangaRates({
    required String? id,
    required String? token,
    int? page,
    int? limit,
    String? status,
    String? censored,
    CancelToken? cancelToken,
  });

  Future<Iterable<UserHistory>> getHistory({
    required String id,
    required String token,
    required int page,
    required int limit,
    int? targetId,
    String? targetType,
    CancelToken? cancelToken,
  });

  Future<Iterable<ShikiClub>> getClubs({
    required String id,
    required String token,
    CancelToken? cancelToken,
  });

  Future<UserRateResp> createUserRate({
    required String token,
    required int userId,
    required int targetId,
    required String status,
    String? targetType = 'Anime',
  });

  Future<UserRateResp> updateUserRate({
    required String token,
    required int rateId,
    String? status,
    int? score,
    int? episodes,
    int? chapters,
    int? rewatches,
    String? text,
  });

  Future<UserRateResp> incrementUserRate({
    required String token,
    required int rateId,
  });

  Future<bool> deleteUserRate({
    required String token,
    required int rateId,
  });
}
