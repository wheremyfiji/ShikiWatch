class Genre {
  int? id;
  String? name;
  String? russian;
  String? kind;

  Genre({this.id, this.name, this.russian, this.kind});

  Genre.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    russian = json['russian'];
    kind = json['kind'];
  }
}
