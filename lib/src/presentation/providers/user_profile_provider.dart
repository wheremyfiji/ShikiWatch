import 'package:flutter/material.dart' as fl;

import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:primer_progress_bar/primer_progress_bar.dart';

import '../../utils/extensions/riverpod_extensions.dart';
import '../../data/data_sources/user_data_src.dart';
import '../../data/repositories/user_repo.dart';
import '../../domain/models/user.dart';
import '../../domain/models/user_profile.dart';
import '../../services/secure_storage/secure_storage_service.dart';

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

  final List<Segment> _segmentsAnime = [];
  List<Segment> get segmentsAnime => _segmentsAnime;

  final List<Segment> _segmentsManga = [];
  List<Segment> get segmentsManga => _segmentsManga;

  int _userAnimesCount = 0;
  int get userAnimesCount => _userAnimesCount;

  int _userMangasCount = 0;
  int get userMangasCount => _userMangasCount;

  Future<void> fetch() async {
    profile = await AsyncValue.guard(
      () async {
        final data = await profileRepository.getUserProfile(
          id: userId,
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

    profile.whenData(
      (value) async {
        _fillSegmentsAnime(value);
        _fillSegmentsManga(value);

        if (userId == SecureStorageService.instance.userId) {
          final nickname = value.nickname ?? '';

          if (nickname.isNotEmpty) {
            SecureStorageService.instance.userNickname = nickname;
            await SecureStorageService.instance.writeUserNickname(nickname);
          }

          final image = value.image?.x160 ?? '';

          if (image.isNotEmpty) {
            SecureStorageService.instance.userProfileImage = image;
            await SecureStorageService.instance.writeUserImage(image);
          }
        }
      },
    );

    notifyListeners();
  }

  void _fillSegmentsAnime(UserProfile data) {
    if (data.stats?.statuses?.anime == null) {
      return;
    }

    for (var e in data.stats!.statuses!.anime!) {
      _userAnimesCount += e.size ?? 0;
      _segmentsAnime.add(
        Segment(
          value: e.size ?? 0,
          color: _getListColor(e.name ?? ''),
          label: fl.Text(_getListName(e.name ?? '')),
        ),
      );
    }
  }

  void _fillSegmentsManga(UserProfile data) {
    if (data.stats?.statuses?.manga == null) {
      return;
    }

    for (var e in data.stats!.statuses!.manga!) {
      _userMangasCount += e.size ?? 0;
      _segmentsManga.add(
        Segment(
          value: e.size ?? 0,
          color: _getListColor(e.name ?? ''),
          label: fl.Text(_getListName(e.name ?? '', isManga: true)),
        ),
      );
    }
  }

  String _getListName(String value, {bool isManga = false}) {
    String status;

    final Map<String, String> map = {
      'planned': 'В планах',
      'watching': isManga ? 'Читаю' : 'Смотрю',
      'completed': isManga ? 'Прочитано' : 'Просмотрено',
      'on_hold': 'Отложено',
      'dropped': 'Брошено'
    };

    status = map[value] ?? 'N/A';

    return status;
  }

  fl.Color _getListColor(String value) {
    fl.Color color;

    const map = {
      'planned': fl.Colors.lime,
      'watching': fl.Colors.deepPurple,
      'completed': fl.Colors.green,
      'on_hold': fl.Colors.blue,
      'dropped': fl.Colors.red
    };

    color = map[value] ?? fl.Colors.grey;

    return color;
  }
}
