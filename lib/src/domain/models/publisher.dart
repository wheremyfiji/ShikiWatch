class Publisher {
  int? id;
  String? name;

  Publisher({this.id, this.name});

  Publisher.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
