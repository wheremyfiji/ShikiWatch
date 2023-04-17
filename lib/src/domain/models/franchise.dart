class Franchise {
  List<Links>? links;
  List<Nodes>? nodes;
  int? currentId;

  Franchise({this.links, this.nodes, this.currentId});

  Franchise.fromJson(Map<String, dynamic> json) {
    if (json['links'] != null) {
      links = <Links>[];
      json['links'].forEach((v) {
        links!.add(Links.fromJson(v));
      });
    }
    if (json['nodes'] != null) {
      nodes = <Nodes>[];
      json['nodes'].forEach((v) {
        nodes!.add(Nodes.fromJson(v));
      });
    }
    currentId = json['current_id'];
  }
  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   if (this.links != null) {
  //     data['links'] = this.links!.map((v) => v.toJson()).toList();
  //   }
  //   if (this.nodes != null) {
  //     data['nodes'] = this.nodes!.map((v) => v.toJson()).toList();
  //   }
  //   data['current_id'] = this.currentId;
  //   return data;
  // }
}

class Links {
  int? id;
  int? sourceId;
  int? targetId;
  int? source;
  int? target;
  int? weight;
  String? relation;

  Links(
      {this.id,
      this.sourceId,
      this.targetId,
      this.source,
      this.target,
      this.weight,
      this.relation});

  Links.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    sourceId = json['source_id'];
    targetId = json['target_id'];
    source = json['source'];
    target = json['target'];
    weight = json['weight'];
    relation = json['relation'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = this.id;
  //   data['source_id'] = this.sourceId;
  //   data['target_id'] = this.targetId;
  //   data['source'] = this.source;
  //   data['target'] = this.target;
  //   data['weight'] = this.weight;
  //   data['relation'] = this.relation;
  //   return data;
  // }
}

class Nodes {
  int? id;
  int? date;
  String? name;
  String? imageUrl;
  String? url;
  int? year;
  String? kind;
  int? weight;

  Nodes(
      {this.id,
      this.date,
      this.name,
      this.imageUrl,
      this.url,
      this.year,
      this.kind,
      this.weight});

  Nodes.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    name = json['name'];
    imageUrl = json['image_url'];
    url = json['url'];
    year = json['year'];
    kind = json['kind'];
    weight = json['weight'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = new Map<String, dynamic>();
  //   data['id'] = this.id;
  //   data['date'] = this.date;
  //   data['name'] = this.name;
  //   data['image_url'] = this.imageUrl;
  //   data['url'] = this.url;
  //   data['year'] = this.year;
  //   data['kind'] = this.kind;
  //   data['weight'] = this.weight;
  //   return data;
  // }
}
