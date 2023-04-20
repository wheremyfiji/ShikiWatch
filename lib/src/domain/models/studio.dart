class Studio {
  int? id;
  String? name;
  String? filteredName;
  bool? real;
  String? image;

  Studio({this.id, this.name, this.filteredName, this.real, this.image});

  Studio.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    filteredName = json['filtered_name'];
    real = json['real'];
    image = json['image'];
  }

  @override
  String toString() => '$filteredName';
}
