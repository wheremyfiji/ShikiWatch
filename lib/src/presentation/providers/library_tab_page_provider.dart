import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/data_sources/user_data_src.dart';
import '../../data/repositories/user_repo.dart';
import '../../domain/models/animes.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final watchingTabPageProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryTabPageController(ref.read(userDataSourceProvider), 'watching');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'watchingTabPageProvider');

final completedTabPageProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryTabPageController(ref.read(userDataSourceProvider), 'completed');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'completedTabPageProvider');

final droppedTabPageProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryTabPageController(ref.read(userDataSourceProvider), 'dropped');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'droppedTabPageProvider');

final onHoldTabPageProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryTabPageController(ref.read(userDataSourceProvider), 'on_hold');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'onHoldTabPageProvider');

final plannedTabPageProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryTabPageController(ref.read(userDataSourceProvider), 'planned');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'plannedTabPageProvider');

final rewatchingTabPageProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryTabPageController(ref.read(userDataSourceProvider), 'rewatching');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'rewatchingTabPageProvider');

class LibraryTabPageController with ChangeNotifier {
  final UserRepository userRepository;
  AsyncValue<List<UserAnimeRates>> animes;
  final String status;

  List<UserAnimeRates> searchAnimes;
  final TextEditingController textEditingController;

  LibraryTabPageController(this.userRepository, this.status)
      : animes = const AsyncValue.loading(),
        textEditingController = TextEditingController(),
        searchAnimes = [] {
    fetch();
  }

  void addAnime({
    required int animeId,
    required Animes anime,
    int? score,
    int? episodes,
    int? rewatches,
    String? status,
    required int rateId,
    required String createdAt,
    required String updatedAt,
  }) {
    if (animes.asData == null) {
      return;
    }
    //UserAnimeRates rate = UserAnimeRates();
    animes.asData!.value.add(
      UserAnimeRates(
        id: rateId,
        score: score,
        status: status,
        episodes: episodes,
        rewatches: rewatches,
        createdAt: createdAt,
        updatedAt: updatedAt,
        anime: anime,
      ),
    );
    notifyListeners();
  }

  void updateAnime({
    required int animeId,
    //required String? currentStatus,
    required String updatedAt,
    //String? status,
    int? score,
    int? episodes,
    int? rewatches,
  }) {
    if (animes.asData == null) {
      return;
    }

    final itemIndex = animes.asData!.value
        .indexWhere((element) => element.anime!.id == animeId);

    if (itemIndex == -1) {
      return;
    }

    final item = animes.asData!.value[itemIndex];
    item.updatedAt = updatedAt;
    if (score != null) item.score = score;
    if (episodes != null) item.episodes = episodes;
    if (rewatches != null) item.rewatches = rewatches;

    notifyListeners();
  }

  void deleteAnime(int animeId) {
    if (animes.asData == null) {
      return;
    }
    //animes = const AsyncValue.loading();
    animes.asData!.value.removeWhere((element) {
      return element.anime!.id == animeId;
    });
    notifyListeners();
  }

  void onSearchChanged(String query) {
    searchAnimes = animes.value!.where((anime) {
      final rusNameLower = anime.anime?.russian?.toLowerCase();
      final nameLower = anime.anime?.name?.toLowerCase();
      final searchLower = query.toLowerCase();

      return rusNameLower!.contains(searchLower) ||
          nameLower!.contains(searchLower);
    }).toList();

    notifyListeners();
  }

  Future<void> fetch() async {
    animes = await AsyncValue.guard(
      () async {
        final updates = await userRepository.getUserAnimeRates(
          id: SecureStorageService.instance.userId,
          token: SecureStorageService.instance.token,
          page: 1,
          limit: 5000,
          status: status,
        );
        return updates.toList();
      },
    );
    notifyListeners();
  }
}
