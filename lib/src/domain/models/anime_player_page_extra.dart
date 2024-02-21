import '../../../anime_lib/models/models.dart';
import '../enums/anime_source.dart';

class PlayerPageExtra {
  final TitleInfo info;

  final int selected;
  final AnimeSource animeSource;
  final List<PlaylistItem> playlist;
  final String startPosition;

  final String? anilibHost;
  final AnilibEpisode? anilibEpisode;

  PlayerPageExtra({
    required this.selected,
    required this.info,
    required this.animeSource,
    required this.startPosition,
    required this.playlist,
    this.anilibEpisode,
    this.anilibHost,
  });
}

class PlaylistItem {
  /// kodik link
  final String? link;
  final String? name;
  final int episodeNumber;
  final LibriaEpisode? libria;
  final AnilibPlayerEpisode? anilibEpisode;

  PlaylistItem({
    required this.episodeNumber,
    required this.link,
    required this.libria,
    required this.name,
    required this.anilibEpisode,
  });
}

class TitleInfo {
  final int shikimoriId;
  final String animeName;
  final String imageUrl;
  final int studioId;
  final String studioName;
  final String studioType;
  final String? additInfo;

  TitleInfo({
    required this.shikimoriId,
    required this.animeName,
    required this.imageUrl,
    required this.studioId,
    required this.studioName,
    required this.studioType,
    required this.additInfo,
  });
}

class LibriaEpisode {
  final String host;
  final String? fnd;
  final String? hd;
  final String? sd;
  final List<int>? opSkip;

  const LibriaEpisode({
    required this.host,
    required this.fnd,
    required this.hd,
    this.sd,
    this.opSkip,
  });
}

class AnilibPlayerEpisode {
  const AnilibPlayerEpisode({
    required this.video,
    required this.subtitles,
  });

  final List<AnilibVideo> video;
  final List<AnilibVideoSubtitle> subtitles;
}
