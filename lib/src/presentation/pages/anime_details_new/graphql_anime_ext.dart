import '../../../domain/models/shiki_image.dart';
import '../../../domain/models/user_rate.dart';
import '../../../domain/enums/shiki_gql.dart';
import '../../../domain/models/anime.dart';

import 'graphql_anime.dart';

extension GraphqlAnimeX on GraphqlAnime {
  Anime get toAnime => Anime(
        id: id,
        name: name,
        russian: russian,
        image: ShikiImage(
          original: '/system/animes/original/$id.jpg',
        ),
        kind: kind.value,
        score: score.toString(),
        status: status.value,
        episodes: episodes,
        episodesAired: episodesAired,
        duration: duration,
        airedOn: airedOn,
        releasedOn: releasedOn,
        anons: status == AnimeStatus.anons,
        ongoing: status == AnimeStatus.ongoing,
        userRate: userRate == null
            ? null
            : UserRate(
                id: userRate!.id,
                score: userRate!.score,
                status: userRate!.status.value,
                text: userRate!.text,
                episodes: userRate!.episodes,
                rewatches: userRate!.rewatches,
                createdAt: userRate!.createdAt?.toIso8601String(),
                updatedAt: userRate!.updatedAt?.toIso8601String(),
              ),
      );
}
