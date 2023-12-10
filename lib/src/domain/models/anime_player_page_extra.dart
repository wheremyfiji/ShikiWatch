import '../enums/anime_source.dart';

class PlayerPageExtra {
  final TitleInfo info;

  final int selected;
  final AnimeSource animeSource;
  final List<PlaylistItem> playlist;
  final String startPosition;

  PlayerPageExtra({
    required this.selected,
    required this.info,
    required this.animeSource,
    required this.startPosition,
    required this.playlist,
  });
}

class PlaylistItem {
  final int episodeNumber;
  final String? link;
  final LibriaEpisode? libria;
  final String? name;

  PlaylistItem({
    required this.episodeNumber,
    required this.link,
    required this.libria,
    required this.name,
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

  const LibriaEpisode({
    required this.host,
    required this.fnd,
    required this.hd,
    this.sd,
  });
}
