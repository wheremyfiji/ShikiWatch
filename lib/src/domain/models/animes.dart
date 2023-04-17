class Animes {
  final int? id;
  final String? name;
  final String? russian;
  final String? url;
  final AnimeImages? image;
  final String? kind;
  final String? score;
  final String? status;
  final int? episodes;
  final int? episodesAired;
  final String? airedOn;
  final String? releasedOn;

  Animes(
      {required this.id,
      required this.name,
      required this.russian,
      required this.url,
      required this.image,
      required this.kind,
      required this.score,
      required this.status,
      required this.episodes,
      required this.episodesAired,
      required this.airedOn,
      required this.releasedOn});

  Animes.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        russian = json['russian'],
        url = json['url'],
        image =
            json['image'] == null ? null : AnimeImages.fromJson(json['image']),
        kind = json['kind'],
        score = json['score'],
        status = json['status'],
        episodes = json['episodes'],
        episodesAired = json['episodes_aired'],
        airedOn = json['aired_on'],
        releasedOn = json['released_on'];
}

class AnimeImages {
  final String? original;
  final String? preview;
  final String? x96;
  final String? x48;

  AnimeImages({
    required this.original,
    required this.preview,
    required this.x96,
    required this.x48,
  });

  AnimeImages.fromJson(Map<String, dynamic> json)
      : original = json['original'],
        preview = json['preview'],
        x96 = json['x96'],
        x48 = json['x48'];
}
