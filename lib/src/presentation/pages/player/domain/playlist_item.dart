import '../../../../../anime365/models/translations.dart';
import '../../../../../anime_lib/models/anilib_playlist.dart';

import 'player_page_extra.dart';

class PlaylistItem {
  PlaylistItem({
    required this.episodeNumber,
    this.kodikPlaylistItem,
    this.libriaPlaylistItem,
    this.anilibPlaylistItem,
    this.anime365PlaylistItem,
  });

  final int episodeNumber;
  final KodikPlaylistItem? kodikPlaylistItem;
  final LibriaPlaylistItem? libriaPlaylistItem;
  final AnilibPlaylist? anilibPlaylistItem;
  final Anime365Translation? anime365PlaylistItem;
}
