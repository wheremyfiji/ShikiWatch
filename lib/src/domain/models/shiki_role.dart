import 'shiki_image.dart';

class ShikiRole {
  final List<String>? roles;
  final List<String>? rolesRussian;
  final ShikiRoleItem? character;
  final ShikiRoleItem? person;

  ShikiRole({
    this.roles,
    this.rolesRussian,
    this.character,
    this.person,
  });

  factory ShikiRole.fromJson(Map<String, dynamic> json) => ShikiRole(
        roles: json["roles"] == null
            ? []
            : List<String>.from(json["roles"]!.map((x) => x)),
        rolesRussian: json["roles_russian"] == null
            ? []
            : List<String>.from(json["roles_russian"]!.map((x) => x)),
        character: json["character"] == null
            ? null
            : ShikiRoleItem.fromJson(json["character"]),
        person: json["person"] == null
            ? null
            : ShikiRoleItem.fromJson(json["person"]),
      );
}

class ShikiRoleItem {
  final int? id;
  final String? name;
  final String? russian;
  final ShikiImage? image;
  final String? url;

  ShikiRoleItem({
    this.id,
    this.name,
    this.russian,
    this.image,
    this.url,
  });

  factory ShikiRoleItem.fromJson(Map<String, dynamic> json) => ShikiRoleItem(
        id: json["id"],
        name: json["name"],
        russian: json["russian"],
        image:
            json["image"] == null ? null : ShikiImage.fromJson(json["image"]),
        url: json["url"],
      );
}
