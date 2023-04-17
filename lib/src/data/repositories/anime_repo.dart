import 'package:dio/dio.dart';

import '../../domain/models/anime.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/franchise.dart';
import '../../domain/models/related_title.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../domain/models/user_rate_resp.dart';

abstract class AnimeRepository {
  //final AnimeRepository _animeRepository;
  //AnimeRepository(this._animeRepository);
  const AnimeRepository();

  Future<Anime> getAnime({
    required int? id,
    String? token,
    CancelToken? cancelToken,
    bool forceRefresh = false,
    bool needToCache = false,
  });

  Future<Iterable<Animes>> getSimilarAnimes({required int? id});

  Future<Franchise> getAnimeFranchise({
    required int? id,
  });

  Future<Iterable<RelatedTitle>> getRelatedTitlesAnime({
    required int? id,
    required CancelToken cancelToken,
  });

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
      String? userToken});

  Future<Iterable<UserAnimeRates>> getUserAnimeRates(
      {required String? id,
      required String? token,
      int? page,
      int? limit,
      String? status,
      String? censored});

  Future<UserRateResp> createUserRate({
    required String token,
    required int userId,
    required int targetId,
    required String status,
    required int score,
    required int episodes,
    int? rewatches,
    String? text,
  });

  Future<UserRateResp> updateUserRate({
    required String token,
    required int rateId,
    String? status,
    int? score,
    int? episodes,
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
