import '../../domain/models/anime_database.dart';

abstract class LocalAnimeDatabaseRepo {
  Stream<List<AnimeDatabase>> getLocalAnimes();
  Future<List<Studio>?> getStudios({required int shikimoriId});
  Future<AnimeDatabase?> getAnime({required int shikimoriId});
  Future<void> updatAnime({
    required int shikimoriId,
    required String animeName,
    required String imageUrl,
  });
  Future<void> deleteEpisode({
    required int shikimoriId,
    required int studioId,
    required int episodeNumber,
  });
  Future<void> updateEpisode({
    required int shikimoriId,
    required String animeName,
    required String imageUrl,
    bool? complete = false,
    String? additionalInfo = '',
    required String timeStamp,
    String? position,
    required int studioId,
    required String studioName,
    required String studioType,
    required int episodeNumber,
  });
  Future<void> migration();
  Future<bool> export({required String path});
  Future<double> getDatabaseSize();
  Future<void> clearDatabase();
}
