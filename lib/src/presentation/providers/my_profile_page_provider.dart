import 'package:flutter/material.dart' as fl;
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/data_sources/profile_data_src.dart';
import '../../data/repositories/profile_repo.dart';
import '../../domain/models/user_friend.dart';
import '../../domain/models/user_profile.dart';
import '../../services/secure_storage/secure_storage_service.dart';

// final userProfileProvider = FutureProvider<UserProfile>((ref) async {
//   final ProfileRepository profileRepository;
//   return await profileRepository.getUserProfile(id: id);
//   // return ref
//   //     .watch(shikimoriRepositoryProvider)
//   //     .getUserProfile(userId: userId, token: token);
// }, name: 'userProfileProvider');

// final userProfileProvider =
//     ChangeNotifierProvider<UserProfileController>((ref) {
//   return;
// });

final userProfileProvider = ChangeNotifierProvider.autoDispose
    .family<UserProfileController, String>((ref, userId) {
  final c = UserProfileController(userId, ref.read(profileDataSourceProvider));
  return c;
}, name: 'userProfileProvider');

class UserProfileController extends fl.ChangeNotifier {
  final String userId;
  final ProfileRepository profileRepository;

  AsyncValue<UserProfile> profile;
  AsyncValue<List<UserFriend>> friends;

  UserProfileController(this.userId, this.profileRepository)
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
        );
        return data;
      },
    );
    friends = await AsyncValue.guard(
      () async {
        final data = await profileRepository.getUserFriends(
          id: userId,
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

    profile.whenData((value) async {
      fillAnimeStat(value);
      fillMangaRanobeStat(value);
      await SecureStorageService.instance
          .writeUserImage(value.image!.x160 ?? '');
    });

    notifyListeners();
  }
}
