class AnimePlayerPageExtra {
  final int studioId;
  final int shikimoriId;
  final int episodeNumber;
  final String animeName;
  final String studioName;
  final String studioType;
  final String episodeLink;
  final String additInfo;
  final String? position;
  final String imageUrl;
  final String startPosition;
  final bool isLibria;
  final LibriaEpisode? libriaEpisode;

  AnimePlayerPageExtra({
    required this.studioId,
    required this.shikimoriId,
    required this.episodeNumber,
    required this.animeName,
    required this.studioName,
    required this.studioType,
    required this.episodeLink,
    required this.additInfo,
    required this.position,
    required this.imageUrl,
    required this.startPosition,
    required this.isLibria,
    this.libriaEpisode,
  });
}

class LibriaEpisode {
  final String host;
  final String? fnd;
  final String? hd;

  const LibriaEpisode({
    required this.host,
    required this.fnd,
    required this.hd,
  });
}
