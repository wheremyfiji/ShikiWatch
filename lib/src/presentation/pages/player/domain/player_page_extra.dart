import '../../../../../anime365/models/translations.dart';
import '../../../../../anime_lib/models/anilib_playlist.dart';
import '../../../../domain/enums/anime_source.dart';

class PlayerPageExtra {
  const PlayerPageExtra({
    required this.titleInfo,
    required this.studio,
    required this.selected,
    required this.animeSource,
    required this.startPosition,
    required this.anilib,
    required this.kodik,
    required this.libria,
    this.anime365,
  });

  final TitleInfo titleInfo;
  final Studio studio;
  final int selected;
  final AnimeSource animeSource;
  final String startPosition;

  final AnilibPlayerList? anilib;
  final List<KodikPlaylistItem>? kodik;
  final LibriaPlaylist? libria;
  final Anime365Playlist? anime365;
}

class TitleInfo {
  const TitleInfo({
    required this.shikimoriId,
    required this.animeName,
    required this.imageUrl,
  });

  final int shikimoriId;
  final String animeName;
  final String imageUrl;
}

class Studio {
  const Studio({
    required this.id,
    required this.name,
    required this.type,
  });

  final int id;
  final String name;
  final String type;
}

class AnilibPlayerList {
  const AnilibPlayerList({
    required this.host,
    required this.playlist,
  });

  final String host;
  final List<AnilibPlaylist> playlist;
}

class KodikPlaylistItem {
  const KodikPlaylistItem({
    required this.number,
    required this.link,
  });

  final int number;
  final String link;
}

class LibriaPlaylist {
  const LibriaPlaylist({
    required this.host,
    required this.playlist,
  });

  final String host;
  final List<LibriaPlaylistItem> playlist;
}

class LibriaPlaylistItem {
  const LibriaPlaylistItem({
    required this.number,
    required this.fnd,
    required this.hd,
    required this.sd,
    required this.name,
    required this.opSkip,
  });

  final int number;
  final String? fnd;
  final String? hd;
  final String? sd;
  final String? name;
  final List<int>? opSkip;
}

class Anime365Playlist {
  const Anime365Playlist(
    this.ts,
  );

  final Anime365Translation ts;
}
