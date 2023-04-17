import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/models/anime_database.dart';
import '../../services/anime_database/anime_database_provider.dart';

final animeLocalHistoryProvider =
    StreamProvider.autoDispose<List<AnimeDatabase>>((ref) {
  final controller = StreamController<List<AnimeDatabase>>();

  final sub = ref.read(animeDatabaseProvider).getLocalAnimes().listen((data) {
    return controller.sink.add(data);
  });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
