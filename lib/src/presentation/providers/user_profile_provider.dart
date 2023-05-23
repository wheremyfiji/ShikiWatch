import 'package:dio/dio.dart';
import 'package:flutter/material.dart' as fl;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shikidev/src/utils/extensions/riverpod_extensions.dart';

import '../../data/data_sources/user_data_src.dart';
import '../../data/repositories/user_repo.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_profile.dart';
import '../../services/secure_storage/secure_storage_service.dart';

//https://shikimori.me/api/users?page=1&limit=10&search=ya_sel

final userProfileProvider = ChangeNotifierProvider.autoDispose
    .family<UserProfileController, String>((ref, userId) {
  //ref.cacheFor();

  final cancelToken = ref.cancelToken();

  final c = UserProfileController(
    userId,
    ref.read(userDataSourceProvider),
    cancelToken,
  );

  return c;
}, name: 'userProfileProvider');

class UserProfileController extends fl.ChangeNotifier {
  final String userId;
  final UserRepository profileRepository;
  final CancelToken cancelToken;

  AsyncValue<UserProfile> profile;
  AsyncValue<List<User>> friends;

  UserProfileController(this.userId, this.profileRepository, this.cancelToken)
      : profile = const AsyncValue.loading(),
        friends = const AsyncValue.loading() {
    fetch();
  }

  List<int> animeStat = [];
  List<int> mangaRanobeStat = [];

  void fillAnimeStat(UserProfile data) {
    if (data.stats?.statuses?.anime != null) {
      for (var e in data.stats!.statuses!.anime!) {
        //if (e.size != null && e.size != 0) {
        //  animeStat.add(e.size!);
        //}
        animeStat.add(e.size ?? 0);
      }
    }
  }

  void fillMangaRanobeStat(UserProfile data) {
    if (data.stats?.statuses?.manga != null) {
      for (var e in data.stats!.statuses!.manga!) {
        // if (e.size != null && e.size != 0) {
        //   mangaRanobeStat.add(e.size!);
        // }
        mangaRanobeStat.add(e.size ?? 0);
      }
    }
  }

  Future<void> fetch() async {
    profile = await AsyncValue.guard(
      () async {
        final data = await profileRepository.getUserProfile(
          id: userId, //1297442 userId
          userToken: SecureStorageService.instance.token,
          cancelToken: cancelToken,
        );
        return data;
      },
    );
    friends = await AsyncValue.guard(
      () async {
        final data = await profileRepository.getUserFriends(
          id: userId,
          cancelToken: cancelToken,
        );
        return data.toList();
      },
    );

    if (animeStat.isNotEmpty) {
      animeStat = [];
    }

    if (mangaRanobeStat.isNotEmpty) {
      mangaRanobeStat = [];
    }

    profile.whenData(
      (value) async {
        fillAnimeStat(value);
        fillMangaRanobeStat(value);
        if (userId == SecureStorageService.instance.userId) {
          SecureStorageService.instance.userNickname = value.nickname ?? '';
          await SecureStorageService.instance
              .writeUserNickname(value.nickname ?? '');

          SecureStorageService.instance.userProfileImage =
              value.image!.x160 ?? '';
          await SecureStorageService.instance
              .writeUserImage(value.image?.x160 ?? '');
        }
      },
    );

    notifyListeners();
  }
}
