import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../../../../aniliberty/models/aniliberty_anime.dart';
import '../../../../utils/extensions/riverpod_extensions.dart';
import '../../../../../aniliberty/aniliberty_api.dart';

class AnilibertySourceParameters extends Equatable {
  final String query;
  final String? type;
  final int? year;
  final bool? isOngoing;

  const AnilibertySourceParameters({
    required this.query,
    this.type,
    this.year,
    this.isOngoing,
  });

  @override
  List<Object?> get props => [query, type, year, isOngoing];
}

final anilibertySourceProvider = FutureProvider.autoDispose
    .family<AnilibertyAnime?, AnilibertySourceParameters>((ref, p) async {
  final anilibriaApi = ref.read(anilibertyApiProvider);
  final cancelToken = ref.cancelToken();

  final search = await anilibriaApi.search(
    query: p.query,
    cancelToken: cancelToken,
  );

  if (search.isEmpty) {
    return null;
  }

  if (p.year != null) {
    search.removeWhere((e) => e.year != p.year);
  }

  if (p.isOngoing != null) {
    search.removeWhere((e) => e.isOngoing != p.isOngoing);
  }

  final title = search.firstOrNull;

  if (title == null) {
    return null;
  }

  final result = await anilibriaApi.anime(
    id: title.id,
    cancelToken: cancelToken,
  );

  return result;
}, name: 'anilibertySourceProvider');
