import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/manga_short.dart';
import '../../data/data_sources/user_data_src.dart';
import '../../data/repositories/user_repo.dart';
import '../../domain/models/user_anime_rates.dart';
import '../../services/secure_storage/secure_storage_service.dart';

final readingMangaTabProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryMangaTabController(ref.read(userDataSourceProvider), 'watching');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'readingMangaTabProvider');

final completedMangaTabProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryMangaTabController(ref.read(userDataSourceProvider), 'completed');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'completedMangaTabProvider');

final droppedMangaTabProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryMangaTabController(ref.read(userDataSourceProvider), 'dropped');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'droppedMangaTabProvider');

final onHoldMangaTabProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryMangaTabController(ref.read(userDataSourceProvider), 'on_hold');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'onHoldMangaTabProvider');

final plannedMangaTabProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryMangaTabController(ref.read(userDataSourceProvider), 'planned');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'plannedMangaTabProvider');

final reReadingMangaTabProvider = ChangeNotifierProvider((ref) {
  final c =
      LibraryMangaTabController(ref.read(userDataSourceProvider), 'rewatching');
  ref.onDispose(() {
    c.textEditingController.dispose();
  });
  return c;
}, name: 'reReadingMangaTabProvider');

class LibraryMangaTabController with ChangeNotifier {
  final UserRepository userRepository;
  AsyncValue<List<UserAnimeRates>> manga;
  final String status;

  List<UserAnimeRates> searchResult;
  final TextEditingController textEditingController;

  LibraryMangaTabController(this.userRepository, this.status)
      : manga = const AsyncValue.loading(),
        textEditingController = TextEditingController(),
        searchResult = [] {
    fetch();
  }

  void addManga({
    required MangaShort mangaInfo,
    int? score,
    int? chapters,
    int? rewatches,
    String? status,
    required int rateId,
    required String createdAt,
    required String updatedAt,
  }) {
    if (manga.asData == null) {
      return;
    }
    manga.asData!.value.add(
      UserAnimeRates(
          id: rateId,
          score: score,
          status: status,
          episodes: null,
          chapters: chapters,
          rewatches: rewatches,
          createdAt: createdAt,
          updatedAt: updatedAt,
          manga: mangaInfo,
          anime: null),
    );
    notifyListeners();
  }

  void updateManga({
    required int mangaId,
    required String updatedAt,
    int? score,
    int? chapters,
    int? rewatches,
  }) {
    if (manga.asData == null) {
      return;
    }

    final itemIndex = manga.asData!.value
        .indexWhere((element) => element.manga!.id == mangaId);

    if (itemIndex == -1) {
      return;
    }

    final item = manga.asData!.value[itemIndex];
    item.updatedAt = updatedAt;
    if (score != null) item.score = score;
    if (chapters != null) item.chapters = chapters;
    if (rewatches != null) item.rewatches = rewatches;

    notifyListeners();
  }

  void deleteManga(int mangaId) {
    if (manga.asData == null) {
      return;
    }
    manga.asData!.value.removeWhere((element) {
      return element.manga!.id == mangaId;
    });
    notifyListeners();
  }

  void onSearchChanged(String query) {
    searchResult = manga.value!.where((title) {
      final rusNameLower = title.manga?.russian?.toLowerCase();
      final nameLower = title.manga?.name?.toLowerCase();
      final searchLower = query.toLowerCase();

      return rusNameLower!.contains(searchLower) ||
          nameLower!.contains(searchLower);
    }).toList();

    notifyListeners();
  }

  Future<void> fetch() async {
    manga = await AsyncValue.guard(
      () async {
        final updates = await userRepository.getUserMangaRates(
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
