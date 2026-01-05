class TitleDetailsPageExtra {
  TitleDetailsPageExtra({
    required this.id,
    required this.label,
  });

  final int id;
  final String label;
}

class AnimeSourcePageExtra {
  AnimeSourcePageExtra({
    required this.shikimoriId,
    required this.epWatched,
    required this.animeName,
    required this.searchName,
    required this.imageUrl,
    required this.searchList,
    required this.year,
    required this.isOngoing,
  });

  final int shikimoriId;
  final int epWatched;
  final String animeName;
  final String searchName;
  final String imageUrl;
  final List<String> searchList;
  final int? year;
  final bool isOngoing;
}
