class ShikiClub {
  final int id;
  final String? name;
  final ShikiClubLogo? logo;
  final bool? isCensored;
  final String? joinPolicy;
  final String? commentPolicy;

  ShikiClub({
    required this.id,
    this.name,
    this.logo,
    this.isCensored,
    this.joinPolicy,
    this.commentPolicy,
  });

  factory ShikiClub.fromJson(Map<String, dynamic> json) => ShikiClub(
        id: json["id"],
        name: json["name"],
        logo:
            json["logo"] == null ? null : ShikiClubLogo.fromJson(json["logo"]),
        isCensored: json["is_censored"],
        joinPolicy: json["join_policy"],
        commentPolicy: json["comment_policy"],
      );
}

class ShikiClubLogo {
  final String? original;
  final String? main;
  final String? x96;
  final String? x73;
  final String? x48;

  ShikiClubLogo({
    this.original,
    this.main,
    this.x96,
    this.x73,
    this.x48,
  });

  factory ShikiClubLogo.fromJson(Map<String, dynamic> json) => ShikiClubLogo(
        original: json["original"],
        main: json["main"],
        x96: json["x96"],
        x73: json["x73"],
        x48: json["x48"],
      );
}
