class CharacterRole {
  final List<String> rolesRu;
  final Character character;

  CharacterRole({
    required this.rolesRu,
    required this.character,
  });

  factory CharacterRole.fromJson(Map<String, dynamic> json) => CharacterRole(
        rolesRu: List<String>.from(json["rolesRu"].map((x) => x)),
        character: Character.fromJson(json["character"]),
      );
}

class Character {
  final int id;
  final String name;
  final String? russian;
  final String? poster;

  Character({
    required this.id,
    required this.name,
    required this.russian,
    required this.poster,
  });

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: int.parse(json["id"]),
        name: json["name"],
        russian: json["russian"],
        poster: json["poster"]?["mainUrl"],
      );
}
