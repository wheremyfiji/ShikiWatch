import 'dart:developer';
import 'dart:convert' as c;
import 'dart:io' as io;

import 'package:collection/collection.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart' as path_prov;
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/config.dart';
import '../../data/repositories/anime_database_repo.dart';
import '../../domain/models/anime_database.dart';

class LocalAnimeDatabaseImpl implements LocalAnimeDatabaseRepo {
  final Isar isardb;

  LocalAnimeDatabaseImpl(this.isardb);

  static Future<LocalAnimeDatabaseImpl> initialization() async {
    //final appDocDir = await path_prov.getApplicationDocumentsDirectory();
    final appDocDir = await path_prov.getApplicationSupportDirectory();
    return LocalAnimeDatabaseImpl(
      await Isar.open(
        [AnimeDatabaseSchema],
        name: "animeDatabase",
        directory: appDocDir.path,
        compactOnLaunch: const CompactCondition(minRatio: 2.0),
      ),
    );
  }

  @override
  Stream<List<AnimeDatabase>> getLocalAnimes() {
    // Query<AnimeDatabase> animeList =
    //     isardb.animeDatabases.where(sort: Sort.asc).build();
    Query<AnimeDatabase> animeList =
        isardb.animeDatabases.where().sortByLastUpdateDesc().build();
    return animeList.watch(fireImmediately: true);
  }

  @override
  Future<List<Studio>?> getStudios({required int shikimoriId}) async {
    final anime = await isardb.animeDatabases
        .filter()
        .shikimoriIdEqualTo(shikimoriId)
        .findFirst();

    return anime?.studios;
  }

  @override
  Future<AnimeDatabase?> getAnime({required int shikimoriId}) async {
    return await isardb.animeDatabases
        .filter()
        .shikimoriIdEqualTo(shikimoriId)
        .findFirst();
  }

  @override
  Future<void> updatAnime({
    required int shikimoriId,
    required String animeName,
    required String imageUrl,
  }) async {
    return;
  }

  @override
  Future<void> deleteEpisode({
    required int shikimoriId,
    required int studioId,
    required int episodeNumber,
  }) async {
    final anime = await isardb.animeDatabases
        .filter()
        .shikimoriIdEqualTo(shikimoriId)
        .findFirst();

    // аниме нету в базе
    if (anime == null) {
      return;
    }

    // возврящает -1 если элемент не найден
    final studioIndex = anime.studios?.indexWhere((e) => e.id == studioId);

    // если такой студии нету
    if (studioIndex == -1) {
      return;
    }

    final updateTime = DateTime.now();

    await isardb.writeTxn(() async {
      // удаляем эпизод
      // anime.studios?[studioIndex!].episodes = [
      //   ...?anime.studios?[studioIndex].episodes
      //       ?.where((element) => element.nubmer != episodeNumber)

      anime.studios?[studioIndex!].episodes = [
        ...?anime.studios?[studioIndex].episodes
            ?.where((element) => element.nubmer != episodeNumber)
      ];
      // обновляем время
      anime.studios?[studioIndex!].updated = updateTime;
      anime.lastUpdate = updateTime;
      await isardb.animeDatabases.put(anime);
    });
  }

  @override
  Future<void> updateEpisode({
    required int shikimoriId,
    required String animeName,
    required String imageUrl,
    required String timeStamp,
    required int studioId,
    required String studioName,
    required String studioType,
    required int episodeNumber,
    bool? complete = false,
    String? additionalInfo = '',
    String? position,
  }) async {
    final anime = await isardb.animeDatabases
        .filter()
        .shikimoriIdEqualTo(shikimoriId)
        .findFirst();

    final updateTime = DateTime.now();

    if (anime == null) {
      //throw Exception('anime ($shikimoriId) not found in db');
      final episode = Episode()
        ..nubmer = episodeNumber
        ..timeStamp = timeStamp
        ..isComplete = complete
        ..additionalInfo = additionalInfo
        ..position = position;

      final studio = Studio()
        ..id = studioId
        ..name = studioName
        ..type = studioType
        ..created = updateTime
        ..updated = updateTime
        ..episodes = [episode];

      final anime = AnimeDatabase()
        ..shikimoriId = shikimoriId
        ..animeName = animeName
        ..imageUrl = imageUrl
        ..lastUpdate = updateTime
        ..studios = [studio];

      await isardb.writeTxn(() async {
        await isardb.animeDatabases.put(anime);
      });
      return;
    }

    final studioList = anime.studios ?? [];

    final studio = studioList.firstWhereOrNull((e) => e.id == studioId);

    if (studio == null) {
      final newEpisode = Episode()
        ..nubmer = episodeNumber
        ..timeStamp = timeStamp
        ..isComplete = complete
        ..additionalInfo = additionalInfo
        ..position = position;

      final newStudio = Studio()
        ..id = studioId
        ..name = studioName
        ..type = studioType
        ..created = updateTime
        ..updated = updateTime
        ..episodes = [newEpisode];

      await isardb.writeTxn(() async {
        anime.animeName = animeName;
        anime.imageUrl = imageUrl;
        anime.lastUpdate = updateTime;
        anime.studios = [...?anime.studios, newStudio];
        await isardb.animeDatabases.put(anime);
      });

      return;
    }

    final episode =
        studio.episodes?.firstWhereOrNull((e) => e.nubmer == episodeNumber);

    final studioIndex = anime.studios?.indexWhere((e) => e.id == studioId);

    if (episode == null) {
      final newEpisode = Episode()
        ..nubmer = episodeNumber
        ..timeStamp = timeStamp
        ..isComplete = complete
        ..additionalInfo = additionalInfo
        ..position = position;

      await isardb.writeTxn(() async {
        anime.studios?[studioIndex!].episodes = [
          ...?anime.studios?[studioIndex].episodes,
          newEpisode
        ];
        anime.studios?[studioIndex!].updated = updateTime;
        anime.animeName = animeName;
        anime.imageUrl = imageUrl;
        anime.lastUpdate = updateTime;
        await isardb.animeDatabases.put(anime);
      });

      return;
    }

    final episodeIndex = anime.studios?[studioIndex!].episodes
        ?.indexWhere((e) => e.nubmer == episodeNumber);

    // надо переписать
    var backStudios = <Studio>[...?anime.studios];
    final needStud = backStudios[studioIndex!];
    final backEpisodeList = needStud.episodes?.toList();

    backStudios.removeAt(studioIndex);
    backEpisodeList?.removeAt(episodeIndex!);

    final updatedEpisode = Episode()
      ..nubmer = episodeNumber
      ..timeStamp = timeStamp
      ..isComplete = complete
      ..additionalInfo = additionalInfo
      ..position = position;

    backEpisodeList?.add(updatedEpisode);

    final newStudio = Studio()
      ..id = needStud.id
      ..name = needStud.name
      ..type = needStud.type
      ..created = needStud.created
      ..updated = updateTime
      ..episodes = backEpisodeList;

    backStudios.add(newStudio);

    anime.studios = backStudios;

    await isardb.writeTxn(() async {
      anime.animeName = animeName;
      anime.imageUrl = imageUrl;
      anime.lastUpdate = updateTime;
      await isardb.animeDatabases.put(anime);
    });
  }

  @override
  Future<void> migration() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(AppConfig.databaseVersionKey);

    if (currentVersion == null) {
      await prefs.setInt(
          AppConfig.databaseVersionKey, AppConfig.databaseVersion);

      return;
    }

    if (currentVersion == AppConfig.databaseVersion) {
      log('No need to migrate', name: 'isar');
      return;
    }

    Future<void> migrate<T>(IsarCollection<T> collection) async {
      await isardb.writeTxn(() async {
        final count = await collection.count();
        for (var i = 0; i < count; i += 50) {
          final data = await collection.where().offset(i).limit(50).findAll();
          await collection.putAll(data);
        }
      });
    }

    log('migrate database', name: 'isar');

    await Future.wait([migrate<AnimeDatabase>(isardb.animeDatabases)]);

    // Update version
    await prefs.setInt(AppConfig.databaseVersionKey, AppConfig.databaseVersion);
  }

  @override
  Future<bool> export({required String path}) async {
    final json =
        await isardb.animeDatabases.where().sortByLastUpdateDesc().exportJson();

    final conv = c.jsonEncode(json);

    final directory = await path_prov.getApplicationSupportDirectory();

    final timestamp = DateTime.now().toLocal().toUtc().millisecondsSinceEpoch;

    final path = p.join(directory.path, 'export');

    bool exists = await io.Directory(path).exists();

    if (!exists) {
      await io.Directory(path).create(recursive: true);
    }

    final file = io.File(p.join(path, 'anime-database-$timestamp.json'));

    return await file.writeAsString(conv).then((value) async {
      await launchUrl(Uri.parse(path));
      return true;
    }).onError((error, stackTrace) => false);
  }

  @override
  Future<void> clearDatabase() async {
    await isardb.writeTxn(() async {
      await isardb.animeDatabases.clear();
    });
  }
}
